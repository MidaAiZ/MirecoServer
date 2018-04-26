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

  belongs_to :dir, -> { with_del },
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
           class_name: 'Index::Workspace::Article'
           # dependent: :destroy

  has_many :son_corpuses_with_del, -> { with_del },
           as: :dir,
           class_name: 'Index::Workspace::Corpus'
           # dependent: :destroy

  has_many :son_folders_with_del, -> { with_del },
           as: :dir,
           class_name: 'Index::Workspace::Folder'
           # dependent: :destroy

  # ------------------------标星-------------------------- #
  has_many :mark_records, as: :file,
                          class_name: 'Index::Workspace::MarkRecord',
                          dependent: :destroy

  # ------------------------删除记录-------------------------- #
  has_one :trash, as: :file,
           class_name: 'Index::Workspace::Trash',
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

  def self.file_type
    :folders
  end

  # ----------------------允许的路径类型---------------------- #
  def allow_dir_types
    [:folders, 0] # 目标目录文件仅允许文件夹或者空, 0代表空,即移动到根目录
  end

  # ------------------------下一级文件------------------------ #
  def profiles user
    fids = folder_nodes
    cids = corpus_nodes
    aids = article_nodes
    folders = (fids.any? && user.all_folders.where(id: fids).includes(:file_seed)) || [] # 子文件夹
    corpuses = (cids.any? && user.all_corpuses.where(id: cids).includes(:file_seed)) || [] # 子文集
    articles = (aids.any? && user.all_articles.where(id: aids).includes(:file_seed)) || [] # 子文章
    # 根据创建日期进行排序
    (folders += corpuses += articles).sort { |x, y|  x.created_at <=> y.created_at }
  end

  private

  def auto_delete_son_roles
    role_ids = role_nodes
    unless role_ids.blank?
      roles = Index::Role::Edit.where(id: role_ids) || []
        roles.each do |role|
          if role.is_author
            role.file_seed.destroy
          else
            role.destroy
          end
        end
    end
  end

  def after_move_dir dir
  end

  def after_delete
    clear_cache
  end

  def after_recover

  end
end
