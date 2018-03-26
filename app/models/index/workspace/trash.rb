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

  #--------------------------删除文件--------------------------- #
  def self.delete_files(file, user = nil) # 加入回收站
    return false if file.is_deleted
    @editor = user || file.own_editor # @editor为文件拥有者
    @file = file; @file_seed = file.file_seed
    ApplicationRecord.transaction do
      if file.is_root? # 根文件
        delete_root
      else
        delete_unroot
      end
      file.update! is_deleted: true # 修改文件本身
      file.clear_cache # 删除文件缓存
      return self.create
    end
    rescue
      return false
  end

  #--------------------------恢复文件--------------------------- #
  def recover_files(editor)
    @file = file; @editor = editor
    @file_seed = file_seed
    ApplicationRecord.transaction do
      if file.is_root? # 根文件
        recover_root
      else
        recover_unroot
      end
      file.update! is_deleted: false
      return delete
    end
    rescue
      return false
  end

  #--------------------------彻底删除--------------------------- #
  def destroy_files
    file = self.file
    file_seed = self.file_seed
    ApplicationRecord.transaction do # 出错将回滚
      if file.is_root? # 根文件
        # 预加载file_seed的所有dependent: :destroy的关联文件, 减少数据库查询次数
        unless file.file_type == :articles # 文章可以直接删除, 无需以下预加载
          file_seed = Index::Workspace::FileSeed.deleted.where(id: file_seed.id).includes(:trashes, :editor_roles, :folders_with_del, corpuses_with_del: [:comments, :thumb_up], articles_with_del: [:comments, :edit_comments, :thumb_up]).first
        end
        file_seed.destroy! # 执行回调, 会删除所有子文件及角色
      else
        destroy!
      end
      return true
    end
  rescue
    return false
  end

  private

  def self.create
    trash = Index::Workspace::Trash.new
    trash.file = @file
    trash.editor = @editor
    trash.file_name = @file.name
    trash.file_seed = @file_seed
    trash.files_count = @files[:files_count] + 1
    trash.save!
    trash
  end

  def self.delete_root
    case @file.file_type
    when :articles
      @files = { files_count: 0 } # 以下创建trash时使用
    when :corpuses
      articles = @file.son_articles
      articles.update_all is_deleted: true
      @files = { files_count: articles.size } # 以下创建trash时使用
    else # :folders
      @files = @file_seed.files
      @files[:articles].update_all is_deleted: true unless @files[:articles].blank?
      @files[:corpuses].update_all is_deleted: true unless @files[:corpuses].blank?
      @files[:folders].update_all is_deleted: true unless @files[:folders].blank?
    end
    check_delete
  end

  def self.check_delete
    if @editor.has_edit_role? :own, @file_seed
      @file_seed.editor_roles.update_all is_deleted: true
    else
      # 退出协同写作
      @editor.all_edit_roles_with_del.find_by_file_seed_id(file_seed.id).destroy # 该查询从缓存中读取
    end
  end

  def self.delete_unroot
    @files = @file.files
    Index::Workspace::Article.unscope(:select).where(id: @files[:articles].map(&:id)).update_all is_deleted: true unless @files[:articles].blank?
    Index::Workspace::Corpus.where(id: @files[:corpuses].map(&:id)).update_all is_deleted: true unless @files[:corpuses].blank?
    Index::Workspace::Folder.where(id: @files[:folders].map(&:id)).update_all is_deleted: true unless @files[:folders].blank?
  end

  def recover_root
    case @file.file_type
    when :articles
      # do nothing
    when :corpuses
      @file.son_articles_with_del.update_all is_deleted: false
    else # :folders
      @files = @file_seed.files
      @files[:articles].update_all is_deleted: false unless @files[:articles].blank?
      @files[:corpuses].update_all is_deleted: false unless @files[:corpuses].blank?
      @files[:folders].update_all is_deleted: false unless @files[:folders].blank?
    end

    @file_seed.editor_roles.update_all is_deleted: false # 该查询从缓存中读取
  end

  def recover_unroot
    @files = @file.files
    Index::Workspace::Article.deleted.unscope(:select).where(id: @files[:articles].map(&:id)).update_all is_deleted: false unless @files[:articles].blank?
    Index::Workspace::Corpus.deleted.where(id: @files[:corpuses].map(&:id)).update_all is_deleted: false unless @files[:corpuses].blank?
    Index::Workspace::Folder.deleted.where(id: @files[:folders].map(&:id)).update_all is_deleted: false unless @files[:folders].blank?
  end
end
