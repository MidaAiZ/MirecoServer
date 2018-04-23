require_relative 'file_model_module'

class Index::Workspace::Corpus < ApplicationRecord
  include FileModel

  mount_uploader :cover, FileCoverUploader # 封面上传

  after_update :update_cache
  after_destroy :auto_delete_son_roles, :clear_cache
  # store_accessor :info, :tbp_counts, :cmt_counts, :read_times # 点赞数/评论数/阅读次数

  belongs_to :file_seed,
             class_name: 'Index::Workspace::FileSeed',
             foreign_key: :file_seed_id
            #  optional: true

  # -----------------------发表副本------------------------ #
  has_one :release, -> { all_state },
          class_name: 'Index::PublishedCorpus',
          foreign_key: :origin_id

  # ---------------------作者和作者角色---------------------- #
  has_many :editor_roles, -> { all_with_del },
           through: :file_seed,
           source: :editor_roles

  has_many :editors,
           through: :editor_roles,
           source: :editor

  has_one :own_editor,
          through: :file_seed,
          source: :own_editor

  # -----------------------文件目录------------------------ #
  belongs_to :dir, -> { with_del },
             polymorphic: true,
             optional: true

  # -----------------------包含文章------------------------ #
  has_many :son_articles,
           as: :dir,
           class_name: 'Index::Workspace::Article'

  has_many :son_articles_with_del, -> { with_del },
           as: :dir,
           class_name: 'Index::Workspace::Article'
           # dependent: :destroy

  # ---------------------包含协同子文件--------------------- #
  has_many :son_roles, as: :dir,
                       class_name: 'Index::Role::Edit'

  # ------------------------标星-------------------------- #
  has_many :mark_records, as: :file,
                          class_name: 'Index::Workspace::MarkRecord',
                          dependent: :destroy

  # ------------------------删除记录-------------------------- #
  has_one :trash, as: :file,
           class_name: 'Index::Workspace::Trash',
           dependent: :destroy

  # -----------------------数据验证------------------------ #
  validates :tag, length: { maximum: 25 }
  validates :name, presence: { message: '文件名不能为空' }, length: { maximum: 255 }
  validates :dir_type, inclusion: { in: ['Index::Workspace::Folder'] }, allow_blank: true
  validate :check_state, on: [:update]

  #--------------------------域--------------------------- #
  scope :shown, -> { where(is_shown: true) }
  scope :root, -> { where(is_inner: false) }
  scope :unroot, -> { where(is_inner: true) }
  scope :deleted, -> { rewhere(is_deleted: true) }
  scope :undeleted, -> { where(is_deleted: false) }
  scope :with_del, -> { unscope(where: :is_deleted) }
  # 简略的文件信息可以提高查询和加载速度
  scope :brief, -> { unscope(:select).select(:id, :name, :tag, :is_shown, :created_at, :updated_at) }
  # 默认域
  default_scope { undeleted.order('index_corpus.id DESC') }

  def publish # 发表文章
    cor = release || build_release(name: name)
    cor.author = own_editor
    begin
      ApplicationRecord.transaction do
        cor.save!
        update! is_shown: true

        # 将该文集下所有已发表文章的corpus_id指向该文集
        son_articles.where(is_shown: true).update(corpus_id: cor.id)
      end
    rescue
      false
    end
    true
  end

  def copy target_dir = nil # 创建副本
    _self = self.class.new
    _self.dir = target_dir || dir
    _self.name = name + (target_dir ? "" : "副本")

    if _self.create(_self.dir, own_editor)
      self.son_articles.each do |a|
        a.copy _self
      end
    end
    _self
  end

  # ------------------------文件类型------------------------ #
  def file_type
    :corpuses
  end

  # ----------------------允许的路径类型---------------------- #
  def allow_dir_types
    [:folders, 0] # 目标目录文件仅允许文件夹或者空, 0代表空,即移动到根目录
  end

  private

  def check_state
    if is_shown
      errors.add(:base, "文集已经发表，不能再修改") if name_changed?
      release && release.toggle_delete(is_deleted) if is_deleted_changed?
    end
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

  def after_move_dir dir

  end

  # after move to trash, not really deleted
  def after_delete
    clear_cache
  end

  def after_recover

  end

  def update_cache
    Cache.new["edit_corpus_#{self.id}"] = self
  end

  def clear_cache
    Cache.new["edit_corpus_#{self.id}"] = nil
  end
end
