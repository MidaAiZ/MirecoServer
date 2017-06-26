class Index::Workspace::Corpus < ActiveRecord::Base
  after_destroy :auto_delete_son_roles, :delete_thumb_up

  belongs_to :file_seed, -> { with_deleted },
             class_name: 'Index::Workspace::FileSeed',
             foreign_key: :file_seed_id

  # ---------------------作者和作者角色---------------------- #
  has_many :editor_roles,
           through: :file_seed,
           source: :editor_roles

  has_many :editors,
           through: :editor_roles,
           source: :editor

  has_one :own_editor,
          through: :file_seed,
          source: :own_editor

  # -----------------------文件目录------------------------ #
  belongs_to :dir,
             polymorphic: true

  # -----------------------包含文章------------------------ #
  has_many :son_articles, -> { no_content },
           as: :dir,
           class_name: 'Index::Workspace::Article'

  has_many :son_articles_with_content, -> { with_content },
           as: :dir,
           class_name: 'Index::Workspace::Article'

  has_many :son_articles_with_deleted, -> { no_content.with_deleted },
           as: :dir,
           class_name: 'Index::Workspace::Article',
           dependent: :destroy

  has_many :son_articles_with_deleted_with_content, -> { with_deleted },
           as: :dir,
           class_name: 'Index::Workspace::Article'

  # ---------------------包含协同子文件--------------------- #
  has_many :son_roles, as: :dir,
                       class_name: 'Index::Role::Edit'

  # -------------------------评论------------------------- #
  has_many :comments, as: :resource,
                      class_name: 'Index::Comment',
                      dependent: :destroy

  # -------------------------赞--------------------------- #
  has_one :thumb_up, as: :resource,
                     class_name: 'Index::ThumbUp',
                     dependent: :destroy

  has_one :thumb_ct, -> { t_counts },
          as: :resource,
          class_name: 'Index::ThumbUp'

  # -----------------------数据验证------------------------ #
  validates :tag, length: { maximum: 25 }
  validates :name, presence: { message: '文件名不能为空' }, length: { maximum: 255 }
  validates :dir_type, inclusion: { in: ['Index::Workspace::Folder'] }, allow_blank: true

  #--------------------------域--------------------------- #
  scope :shown, -> { where(is_shown: true) }
  scope :root, -> { where(is_inner: false) }
  scope :unroot, -> { where(is_inner: true) }
  scope :deleted, -> { rewhere(is_deleted: true) }
  scope :undeleted, -> { where(is_deleted: false) }
  scope :with_deleted, -> { rewhere(is_deleted: [true, false]) }
  # 简略的文件信息可以提高查询和加载速度
  scope :brief, -> { unscope(:select).select(:id, :name, :tag, :is_shown, :created_at, :updated_at) }
  scope :sort, ->(tag) { where(index_corpus.tag(LIKE("'", "%#{tag}"))) }
  # 默认域
  default_scope { undeleted.order('index_corpus.id DESC') }

  #---------------------------搜索-----------------------------
  def self.filter(cdt = {}, offset = 0, limit = 100)
    allow_hash = { 'name' => 'LIKE', 'tag' => 'LIKE' } # 允许查询的字段集
    keys = allow_hash.keys
    sql_arr = []
    cdt.keys.each do |key|
      if keys.include? key
        sql_arr.push "\"index_corpus\".\"#{key}\" #{allow_hash[key]} \'#{cdt[key]}\'" unless cdt[key].blank?
      end
    end
    sql = ''
    sql_arr.each do |s| # 拼接条件
      sql += s
      sql += 'OR' if s != sql_arr.last
    end
    sql.blank? ? nil : Index::Workspace::Corpus.where(sql).offset(offset).limit(limit)
  end

  # ---------------------判断是否是协作文件---------------------- #
  def is_cooperate?
    file_seed.editors_count > 1
  end

  # ------------------------文件类型------------------------ #
  def file_type
    :corpuses
  end

  # --------------------------赞--------------------------- #
  def thumb_ups
    Index::ThumbUp.get(self, slef.file_type)
  end

  # -------------------------赞数-------------------------- #
  def thumb_up_counts
    Index::ThumbUp.counts(self, slef.file_type)
  end

  # ------------------------判断赞------------------------- #
  def has_thumb_up?(user)
    Index::ThumbUp.has?(self, slef.file_type, user)
  end

  # ----------------------判断是否为根文件-------------------- #
  def is_root?
    file_seed.root_file_id == id && file_seed.root_file_type == itself.class.name
  end

  # ----------------------允许的路径类型---------------------- #
  def allow_dir_types
    [:folders, 0] # 目标目录文件仅允许文件夹或者空, 0代表空,即移动到根目录
  end

  # ------------------------文件数目------------------------ #
  def files
    articles = (son_articles_with_deleted if info['articles']) || []
    { files_count: articles.to_ary.size, articles: articles, corpuses: [], folders: [] }
  end

  # -----------------------创建并设置目录----------------------- #
  def create(target_dir, user)
    Index::Workspace::FileSeed.create(self, target_dir, user)
  end

  # ------------------------移动文件------------------------ #
  def move_dir(target_file, user)
    Index::Workspace::FileSeed.move_dir self, target_file, user
  end

  # -------------------------删除文件------------------------- #
  def delete_files(user = nil)
    Index::Workspace::Trash.delete_files(self, user)
  end

  # -------------------------回收站------------------------- #
  def trash
    Index::Workspace::Trash.find_by file_id: id, file_type: 'Index::Workspace::Corpus'
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

  def delete_thumb_up
    # Index::ThumbUp.destroy self
  end
end
