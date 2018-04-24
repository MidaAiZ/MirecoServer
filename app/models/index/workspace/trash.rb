class Index::Workspace::Trash < ApplicationRecord
  store_accessor :info, :article_nodes, :corpus_nodes, :folder_nodes

  belongs_to :editor,
             class_name: 'Index::User',
             foreign_key: 'user_id'

  belongs_to :file, -> { with_del },
             polymorphic: true

  default_scope { order(id: :DESC) }

  #--------------------------删除文件--------------------------- #
  def self.delete_files file # 加入回收站
    return false if file.is_deleted
    _files = file.files(false)
    _files[file.file_type].push file # add file itself
    files = _files[:articles] + _files[:corpuses] + _files[:folders]
    files_count = 0
    ApplicationRecord.transaction do
      files.each do |f|
        files_count += f.delete!
      end
      delete_edit_role(file) if file.is_root? # 根文件
      return self.create!(file, _files, files_count)
    end
    # rescue
    #   return false
  end

  #--------------------------恢复文件--------------------------- #
  def recover_files
    return false if file.dir && file.dir.is_deleted

    files = self.files
    ApplicationRecord.transaction do
      files.each do |f|
        f.recover!
      end
      recover_edit_role(file) if file.is_root? # 根文件
      return self.delete
    end
    # rescue
    #   return false
  end

  #--------------------------彻底删除--------------------------- #
  def destroy_files
    if file.is_root?
      file.file_seed.destroy!
    else
      files = self.files
      ApplicationRecord.transaction do
        files.each do |f|
          f.destroy!
        end
      end
    end
    true
  # rescue
  #   return false
  end

  def files
    del_articles = Index::Workspace::Article.with_del.where(id: article_nodes) || []
    del_corpuses = Index::Workspace::Corpus.with_del.where(id: corpus_nodes) || []
    del_folders = Index::Workspace::Folder.with_del.where(id: folder_nodes) || []
    del_articles + del_corpuses + del_folders
  end

  private

  def self.create! file, files, files_count
    trash = self.new
    trash.file = file
    trash.file_name = file.name
    trash.editor = file.own_editor
    trash.files_count = files_count
    trash.article_nodes = files[:articles].map {|a| a.id}
    trash.corpus_nodes = files[:corpuses].map {|c| c.id}
    trash.folder_nodes = files[:folders].map {|f| f.id}

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
