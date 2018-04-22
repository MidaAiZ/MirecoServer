class Index::Workspace::Trash < ApplicationRecord
  belongs_to :file_seed,
             class_name: 'Index::Workspace::FileSeed',
             foreign_key: 'file_seed_id'

  belongs_to :editor,
             class_name: 'Index::User',
             foreign_key: 'user_id'

  belongs_to :file, -> { with_del },
             polymorphic: true,
             dependent: :destroy

  default_scope { order(id: :DESC) }

  #--------------------------删除文件--------------------------- #
  def self.delete_files(file, user) # 加入回收站
    return false if file.is_deleted
    ApplicationRecord.transaction do
      files_count = file.delete! user
      delete_edit_role(file) if file.is_root? # 根文件
      return self.create!(file, user, files_count)
    end
    # rescue
    #   return false
  end

  #--------------------------恢复文件--------------------------- #
  def recover_files(editor)
    ApplicationRecord.transaction do
       file = self.file
       file.recover! editor
       recover_edit_role(file) if file.is_root? # 根文件
       return self.delete
    end
    # rescue
    #   return false
  end

  #--------------------------彻底删除--------------------------- #
  def destroy_files
    file = self.file
    file_seed = file.file_seed
    ApplicationRecord.transaction do # 出错将回滚
      if file.is_root? # 根文件
        file_seed.destroy! # 执行回调, 会删除所有子文件及角色
      else
        self.destroy!
      end
    end
  rescue
    return false
  end

  private

  def self.create! file, editor, files_count
    trash = self.new
    trash.file = file
    trash.editor = editor
    trash.file_name = file.name
    trash.file_seed = file.file_seed
    trash.files_count = files_count
    trash.save!
    trash
  end

  def self.delete_edit_role file
    file.file_seed.editor_roles.update_all is_deleted: true
  end

  def recover_edit_role file
    file.file_seed.editor_roles.update_all is_deleted: false # 该查询从缓存中读取
  end
end
