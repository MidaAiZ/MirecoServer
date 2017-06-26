class Index::Workspace::Folder < ActiveRecord::Base
  after_destroy :auto_delete_son_roles

  belongs_to :file_seed, -> { with_deleted },
             class_name: 'Index::Workspace::FileSeed',
             foreign_key: :file_seed_id

  has_many :editor_roles,
           through: :file_seed,
           source: :editor_roles

  has_many :editors,
           through: :editor_roles,
           source: :editor

  has_one :own_editor,
          through: :file_seed,
          source: :own_editor

  belongs_to :dir,
             polymorphic: true

  has_many :son_articles, -> { no_content },
           as: :dir,
           class_name: 'Index::Workspace::Article'

  has_many :son_corpuses,
           as: :dir,
           class_name: 'Index::Workspace::Corpus'

  has_many :son_folders,
           as: :dir,
           class_name: 'Index::Workspace::Folder'

  has_many :son_articles_with_deleted, -> { no_content.with_deleted },
           as: :dir,
           class_name: 'Index::Workspace::Article',
           dependent: :destroy

  has_many :son_corpuses_with_deleted, -> { with_deleted },
           as: :dir,
           class_name: 'Index::Workspace::Corpus',
           dependent: :destroy

  has_many :son_folders_with_deleted, -> { with_deleted },
           as: :dir,
           class_name: 'Index::Workspace::Folder',
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
  scope :with_deleted, -> { rewhere(is_deleted: [true, false]) }
  # 默认域
  default_scope { undeleted.order('index_folders.id DESC') }
  # 简略的文件信息可以提高查询和加载速度
  scope :brief, -> { unscope(:select).select(:id, :name, :created_at, :updated_at) }

  #---------------------------搜索-----------------------------
  def self.filter(cdt = {}, offset = 0, limit = 100)
    allow_hash = { 'name' => 'LIKE', 'tag' => 'LIKE' } # 允许查询的字段集
    keys = allow_hash.keys
    sql_arr = []
    cdt.keys.each do |key|
      if keys.include? key
        sql_arr.push "\"index_folders\".\"#{key}\" #{allow_hash[key]} \'#{cdt[key]}\'" unless cdt[key].blank?
      end
    end
    sql = ''
    sql_arr.each do |s| # 拼接条件
      sql += s
      sql += 'OR' if s != sql_arr.last
    end
    sql.blank? ? nil : Index::Workspace::Folder.where(sql).offset(offset).limit(limit)
  end


  # --------------------判断是否是协作文件--------------------- #
  def is_cooperate?
    file_seed.editors_count > 1
  end

  # ------------------------文件类型------------------------- #
  def file_type
    :folders
  end

  # ----------------------判断是否为根文件--------------------- #
  def is_root?
    file_seed.root_file_id == id && file_seed.root_file_type == itself.class.name
  end

  # ----------------------允许的路径类型---------------------- #
  def allow_dir_types
    [:folders, 0] # 目标目录文件仅允许文件夹或者空, 0代表空,即移动到根目录
  end

  # ------------------------所有子文件------------------------ #
  def files
    t = Time.now

    article_ids = info['articles']
    corpus_ids = info['corpuses']
    folder_ids = info['folders']
    articles = (son_articles_with_deleted if article_ids) || []
    corpuses = (son_corpuses_with_deleted if corpus_ids) || []
    folders = (son_folders_with_deleted if folder_ids) || []
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
    return Index::Workspace::Trash.delete_files(self, user)
  end

  # --------------------------回收站-------------------------- #
  def trash
    Index::Workspace::Trash.find_by file_id: id, file_type: 'Index::Workspace::Folder'
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
end
