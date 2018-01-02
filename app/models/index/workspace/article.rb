require_relative 'file_model_module'

class Index::Workspace::Article < ApplicationRecord
  include FileModel

  mount_uploader :cover, FileCoverUploader # 封面上传

  after_update :update_cache
  after_destroy :delete_thumb_up, :clear_cache
  store_accessor :info, :tbp_counts, :cmt_counts, :rd_times # 点赞数/评论数/阅读次数

  belongs_to :file_seed,
             class_name: 'Index::Workspace::FileSeed',
             foreign_key: :file_seed_id

  # -----------------------文章内容------------------------ #
  has_one :content,
          class_name: 'Index::Workspace::ArticleContent',
          foreign_key: :article_id

  # ---------------------作者和作者角色---------------------- #
  has_many :editor_roles, -> { all_with_del },
           through: :file_seed,
           source: :editor_roles

  has_one :own_editor,
          through: :file_seed,
          source: :own_editor

  has_many :editors,
           through: :editor_roles,
           source: :editor

  has_one :own_editor,
          through: :file_seed,
          source: :own_editor

  # -----------------------文件目录------------------------ #
  belongs_to :dir,
             polymorphic: true,
             optional: true

  # -----------------------读者评论------------------------ #
  has_many :comments, as: :resource,
                      class_name: 'Index::Comment',
                      dependent: :destroy

  # -----------------------编辑评论------------------------ #
  has_many :edit_comments, as: :resource,
                           class_name: 'Index::Workspace::EditComment',
                           dependent: :destroy

  # -------------------------赞--------------------------- #
  has_one :thumb_up, as: :resource,
                     class_name: 'Index::ThumbUp',
                     dependent: :destroy

  has_one :thumb_ct, -> { t_counts },
          as: :resource,
          class_name: 'Index::ThumbUp'

  # ------------------------历史-------------------------- #
  has_many :history,
           class_name: 'Index::Workspace::HistoryArticle',
           foreign_key: :article_id,
           dependent: :destroy

  # ------------------------标星-------------------------- #
  has_many :mark_records, as: :file,
                          class_name: 'Index::Workspace::MarkRecord',
                          dependent: :destroy


  # 数据验证
  validates :tag, length: { maximum: 25 }
  validates :name, presence: { message: '文件名不能为空' }, length: { maximum: 255 }
  validates :dir_type, inclusion: { in: ['Index::Workspace::Corpus', 'Index::Workspace::Folder'] }, allow_blank: true

  #----------------------------域------------------------------

  scope :shown, -> { where(is_shown: true) }
  scope :root, -> { where(is_inner: false) }
  scope :unroot, -> { where(is_inner: true) }
  scope :deleted, -> { rewhere(is_deleted: true) }
  scope :undeleted, -> { where(is_deleted: false) }
  scope :with_del, -> { unscope(where: :is_deleted) }
  scope :sort, ->(tag) { where('index_articles.tag LIKE ?', "%#{tag}") }
  # 默认作用域, 不包含content字段, id降序, 未删除的文章
  default_scope { undeleted.order('index_articles.id DESC') }

  def html_content
    self.content.content.safe_html
  end

  # ------------------------文件类型------------------------- #
  def file_type
    :articles
  end

  # ----------------------允许的路径类型----------------------- #
  def allow_dir_types
    [:corpuses, :folders, 0] # 目标目录文件仅允许文件夹或者空, 0代表空,即移动到根目录
  end

  # ------------------------子文件数目------------------------ #
  def files
    { files_count: 0, articles: [], corpuses: [], folders: [] }
  end

  # -------------------------阅读次数------------------------- #
  def add_read_times mark
    prefix = read_prefix
    puts ReadWorker.perform_at(3.hours.from_now, self.id, prefix) if $redis.EXISTS(prefix) == 0
    $redis.SADD(read_prefix, mark)
  end

  def read_times
    (self.rd_times || 0) + $redis.SCARD(read_prefix)
  end

  def update_cache
    Cache.new["edit_article_#{self.id}"] = self
    Cache.new["article_#{self.id}"] = self
  end

  def clear_cache
    Cache.new["edit_article_#{self.id}"] = nil
    Cache.new["article_#{self.id}"] = nil
  end

  private

  def read_prefix
    $redis.select 3
    "index_#{self.id}_article_readtimes"
  end

end
