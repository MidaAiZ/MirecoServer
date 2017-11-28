require_relative 'file_model_module'

class Index::Workspace::Folder < ApplicationRecord
  include FileModel

  after_update :update_cache
  after_destroy :auto_delete_son_roles, :clear_cache

  belongs_to :file_seed,
             class_name: 'Index::Workspace::FileSeed',
             foreign_key: :file_seed_id

  has_many :editor_roles, -> { all_with_del },
           through: :file_seed,
           source: :editor_roles

  has_many :editors,
           through: :editor_roles,
           source: :editor

  has_one :own_editor,
          through: :file_seed,
          source: :own_editor

  belongs_to :dir,
             polymorphic: true,
             optional: true

  has_many :son_articles,
           as: :dir,
           class_name: 'Index::Workspace::Article'

  has_many :son_corpuses,
           as: :dir,
           class_name: 'Index::Workspace::Corpus'

  has_many :son_folders,
           as: :dir,
           class_name: 'Index::Workspace::Folder'

  has_many :son_articles_with_del, -> { with_del },
           as: :dir,
           class_name: 'Index::Workspace::Article',
           dependent: :destroy

  has_many :son_corpuses_with_del, -> { with_del },
           as: :dir,
           class_name: 'Index::Workspace::Corpus',
           dependent: :destroy

  has_many :son_folders_with_del, -> { with_del },
           as: :dir,
           class_name: 'Index::Workspace::Folder',
           dependent: :destroy

  # ------------------------标星-------------------------- #
  has_many :mark_records, as: :file,
                          class_name: 'Index::Workspace::MarkRecord',
                          dependent: :destroy

  # ---------------------包含协同子文件--------------------- #
  has_many :son_roles, as: :dir,
                       class_name: 'Index::Role::Edit'

  # -------------------------验证------------------------- #
  validates :name, presence: { message: '文件名不能为空' },
                   length: { minimum: 1, maximum: 32 },
                   allow_blank: false
  validates :dir_type, inclusion: { in: ['Index::Workspace::Folder'] }, allow_blank: true

  #----------------------------域------------------------------
  scope :shown, -> { where(is_shown: true) }
  scope :deleted, -> { rewhere(is_deleted: true) }
  scope :undeleted, -> { where(is_deleted: false) }
  scope :with_del, -> { unscope(where: :is_deleted) }
  # 默认域
  default_scope { undeleted.order('index_folders.id DESC') }
  # 简略的文件信息可以提高查询和加载速度
  scope :brief, -> { unscope(:select).select(:id, :name, :created_at, :updated_at) }

  # ------------------------文件类型------------------------- #
  def file_type
    :folders
  end

  # ----------------------允许的路径类型---------------------- #
  def allow_dir_types
    [:folders, 0] # 目标目录文件仅允许文件夹或者空, 0代表空,即移动到根目录
  end

  # ------------------------下一级文件------------------------ #
  def profiles user
    fids = info['folders']
    cids = info['corpuses']
    aids = info['articles']
    folders = (fids && user.all_folders.where(id: fids).includes(:file_seed)) || [] # 子文件夹
    corpuses = (cids && user.all_corpuses.where(id: cids).includes(:file_seed)) || [] # 子文集
    articles = (aids && user.all_articles.where(id: aids).includes(:file_seed)) || [] # 子文章
    # 根据创建日期进行排序
    (folders += corpuses += articles).sort { |x, y|  x.created_at <=> y.created_at }
  end


  # ------------------------所有子文件------------------------ #
  def files
    t = Time.now

    article_ids = info['articles']
    corpus_ids = info['corpuses']
    folder_ids = info['folders']
    articles = (son_articles_with_del if article_ids) || []
    corpuses = (son_corpuses_with_del if corpus_ids) || []
    folders = (son_folders_with_del if folder_ids) || []
    # 返回的文件hash
    files_hash = { files_count: 0, articles: [], corpuses: [], folders: [] }

    corpuses.each do |c| # 将所有子文章并入articles
      files_hash[:articles] += c.son_articles if c.info[:articles]
    end
    folders.each do |f|
      new_files_hash = f.files # 递归获取子文件夹的文件
      files_hash[:files_count] += new_files_hash[:files_count]
      files_hash[:articles] += new_files_hash[:articles]
      files_hash[:corpuses] += new_files_hash[:corpuses]
      files_hash[:folders] += new_files_hash[:folders]
    end

    files_count = articles.to_ary.size + corpuses.size + folders.size
    files_hash[:files_count] += files_count
    files_hash[:articles] += articles
    files_hash[:corpuses] += corpuses
    files_hash[:folders] += folders
    puts '输出时间消耗------------------------------------------------------------'
    puts Time.now - t

    files_hash
  end

  def auto_delete_son_roles
    role_ids = info['son_roles']
    unless role_ids.blank?
      roles = Index::Role::Edit.where(id: role_ids)
      if roles
        roles.each do |role|
          if role.name == 'own'
            role.file_seed.destroy
          else
            role.destroy
          end
        end
      end
    end
  end

  def update_cache
    Cache.new["edit_folder_#{self.id}"] = self
  end

  def clear_cache
    Cache.new["edit_folder_#{self.id}"] = nil
  end
end
