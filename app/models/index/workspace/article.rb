class Index::Workspace::Article < ActiveRecord::Base
  after_destroy :delete_thumb_up

  belongs_to :file_seed, -> { with_deleted },
             class_name: 'Index::Workspace::FileSeed',
             foreign_key: :file_seed_id

  # ---------------------作者和作者角色---------------------- #
  has_many :editor_roles,
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
             polymorphic: true

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

  # 数据验证
  validates :tag, length: { maximum: 25 }
  validates :name, presence: { message: '文件名不能为空' }, length: { maximum: 255 }
  validates :content, presence: { message: '内容不能为空' }, length: { maximum: 100_000 }
  validates :dir_type, inclusion: { in: ['Index::Workspace::Corpus', 'Index::Workspace::Folder'] }, allow_blank: true

  #----------------------------域------------------------------

  scope :shown, -> { where(is_shown: true) }
  scope :root, -> { where(is_inner: false) }
  scope :unroot, -> { where(is_inner: true) }
  scope :deleted, -> { rewhere(is_deleted: true) }
  scope :undeleted, -> { where(is_deleted: false) }
  scope :with_deleted, -> { rewhere(is_deleted: [true, false]) }
  # 由于文章的内容一般比较大(text), 所以当批量查询数据库时应该避开content字段
  scope :no_content, -> { select(:id, :name, :tag, :is_shown, :is_deleted, :file_seed_id, :is_marked, :created_at, :updated_at, :dir_type, :dir_id) }
  scope :with_content, -> { unscope(:select) }
  # 简略的文件信息可以提高查询和加载速度
  scope :brief, -> { unscope(:select).select(:id, :name, :tag, :is_shown, :created_at, :updated_at) }
  scope :sort, ->(tag) { where('index_articles.tag LIKE ?', "%#{tag}") }
  # 默认作用域, 不包含content字段, id降序, 未删除的文章
  default_scope { undeleted.order('index_articles.id DESC') }

  #--------------------------搜索----------------------------#
  def self.filter(cdt = {}, offset = 0, limit = 100)
    allow_hash = { 'name' => 'LIKE', 'tag' => 'LIKE' } # 允许查询的字段集
    keys = allow_hash.keys
    sql_arr = []
    cdt.keys.each do |key|
      if keys.include? key
        sql_arr.push "\"#{key}\" #{allow_hash[key]} \'#{cdt[key]}\'" unless cdt[key].blank?
      end
    end
    sql = ''
    sql_arr.each do |s| # 拼接条件
      sql += s
      sql += 'OR' if s != sql_arr.last
    end
    sql.blank? ? nil : Index::Workspace::Article.where(sql).offset(offset).limit(limit)
  end

  # ---------------------判断是否是协作文件---------------------- #
  def is_cooperate?
    file_seed.editors_count > 1
  end

  # ------------------------文件类型------------------------- #
  def file_type
    :articles
  end

  # --------------------------赞--------------------------- #
  def thumb_ups
    Index::ThumbUp.get(self)
  end

  # -------------------------赞数-------------------------- #
  def thumb_up_counts
    Index::ThumbUp.counts(self)
  end

  # ------------------------判断赞------------------------- #
  def has_thumb_up?(user)
    Index::ThumbUp.has?(self, user)
  end

  # ----------------------判断是否为根文件--------------------- #
  def is_root?
    file_seed.root_file_id == id && file_seed.root_file_type == itself.class.name
  end

  # ----------------------允许的路径类型----------------------- #
  def allow_dir_types
    [:corpuses, :folders, 0] # 目标目录文件仅允许文件夹或者空, 0代表空,即移动到根目录
  end

  # ------------------------子文件数目------------------------ #
  def files
    { files_count: 0, articles: [], corpuses: [], folders: [] }
  end

  # ----------------------创建并设置目录----------------------- #
  def create(target_dir, user)
    Index::Workspace::FileSeed.create(self, target_dir, user)
  end

  # -------------------------移动文件------------------------- #
  def move_dir(target_file, user)
    Index::Workspace::FileSeed.move_dir self, target_file, user
  end

  # -------------------------删除文件------------------------- #
  def delete_file(user = nil)
    Index::Workspace::Trash.delete_files(self, user)
  end

  # --------------------------回收站-------------------------- #
  def trash
    Index::Workspace::Trash.find_by file_id: id, file_type: 'Index::Workspace::Article'
  end

  def delete_thumb_up
    # Index::ThumbUp.destroy self
  end
end
