class Index::User < ApplicationRecord
  after_update :update_cache

  rolify # 角色管理

  mount_uploader :avatar, UserAvatarUploader # 头像上传

  # 用于上传头像时保存图片参数
  attr_accessor :x, :y, :width, :height, :rotate

  # 使用插件建立用户密码验证体系
  has_secure_password

  #----------------------------关联----------------------------

  has_many :edit_roles,
           class_name: 'Index::Role::Edit',
           foreign_key: 'user_id'

  has_many :all_edit_roles, -> { all_dir },
           class_name: 'Index::Role::Edit',
           foreign_key: 'user_id'

  has_many :all_edit_roles_with_del, -> { all_with_del },
           class_name: 'Index::Role::Edit',
           foreign_key: 'user_id'

  has_many :file_seeds,
           through: :edit_roles,
           source: :file_seed

  has_many :all_file_seeds,
           through: :all_edit_roles,
           source: :file_seed

  has_many :articles, -> { undeleted },
           through: :file_seeds,
           source: :root_file,
           source_type: 'Index::Workspace::Article'

  has_many :corpuses, -> { undeleted },
           through: :file_seeds,
           source: :root_file,
           source_type: 'Index::Workspace::Corpus'

  has_many :folders, -> { undeleted },
           through: :file_seeds,
           source: :root_file,
           source_type: 'Index::Workspace::Folder'

  has_many :all_articles,
           through: :all_file_seeds,
           source: :articles

  has_many :all_corpuses,
           through: :all_file_seeds,
           source: :corpuses

  has_many :all_folders,
           through: :all_file_seeds,
           source: :folders

  # has_many :marked_files,
  #           class_name: 'Index::Workspace::MarkRecord',
  #           foreign_key: :user_id

  # has_many :all_articles_with_del, -> { with_del },
  #          through: :file_seeds,
  #          source: :articles_with_del
  #
  # has_many :all_corpuses_with_del, -> { with_del },
  #          through: :file_seeds,
  #          source: :corpuses_with_del
  #
  # has_many :all_folders_with_del, -> { with_del },
  #          through: :file_seeds,
  #          source: :folders_with_del

  # -----------------------标星文件----------------------- #


  has_many :mark_records, ->(id) { where(user_id: id) },
           through: :file_seeds,
           source: :mark_records

  #--------------------------回收站--------------------------- #

  has_many :trashes,
           class_name: 'Index::Workspace::Trash',
           foreign_key: :user_id

  has_and_belongs_to_many :roles, join_table: :index_users_roles

  #--------------------------数据验证--------------------------

  validates :number, presence: true, uniqueness: { message: '该帐号已被注册' },
                     length: { minimum: 2, maximum: 16 },
                     format: { with: Validate::VALID_ACCOUNT_REGEX },
                     allow_blank: false
  validates :password, presence: true, length: { minimum: 6, maximum: 20 },
                       format: { with: Validate::VALID_PASSWORD_REGEX },
                       allow_blank: false, on: [:create]
  validates :password_digest, presence: true, allow_blank: false, on: [:update]
  validates :email, presence: false, uniqueness: { message: '该邮箱已被注册' },
                    length: { maximum: 255 },
                    format: { with: Validate::VALID_EMAIL_REGEX },
                    allow_blank: true
  validates :phone, presence: true, uniqueness: { message: '该手机号已被注册' },
                    format: { with: Validate::VALID_PHONE_REGEX },
                    allow_blank: false
  validates :intro, length: { maximum: 255 }, allow_blank: true

  #----------------------------域------------------------------
  scope :brief, -> { select(:id, :number, :name, :avatar) }
  default_scope { order('index_users.id DESC') }

  #---------------------------搜索-----------------------------

  # 实现帐号搜索功能
  def self.filter(cdt = {})
    allow_hash = { 'number' => 'LIKE', 'email' => '=', 'phone' => '=' } # 允许查询的字段集
    keys = allow_hash.keys
    sql_arr = []
    cdt.keys.each do |key|
      if keys.include? key
        sql_arr.push "\"index_users\".\"#{key}\" #{allow_hash[key]} \'#{cdt[key]}\'" unless cdt[key].blank?
      end
    end
    sql = ''
    sql_arr.each do |s| # 拼接条件
      sql += s
      sql += 'OR' if s != sql_arr.last
    end
    sql.blank? ? nil : Index::User.where(sql).limit(10)
  end

  #--------------------------编辑权限---------------------------

  # 添加编辑权限
  def add_edit_role(name, resource)
    return false if name.nil? || resource.nil?
    return nil unless file_seed = get_file_seed(resource)
    unless file_seeds.find_by_id file_seed.id # 未曾添加过该权限
      role = Index::Role::Edit.new(name: name)
      ApplicationRecord.transaction do
        file_seed.editors_count += 1
        role.file_seed = file_seed
        edit_roles << role
        file_seed.save!
        role.save!
      end
    end
    role && role.id ? role : false
  end

  # 更新编辑权限
  # 可更新权限的附加字段, 例如: is_marked, editor_name
  def update_edit_role(attrs = {}, resource)
    return false if attrs.blank? || resource.nil?
    return false unless file_seed = get_file_seed(resource)
    role = all_edit_roles_with_del.find_by(file_seed_id: file_seed.id)
    if role
      role.update!(attrs)
      bool = true
    end
    bool ||= false
  end

  # 移除编辑权限
  def remove_edit_role(resource)
    return false if resource.nil?
    return false unless file_seed = get_file_seed(resource)
    role = all_edit_roles_with_del.find_by(file_seed_id: file_seed.id)
    if role
      ApplicationRecord.transaction do
        role.destroy!
        file_seed.editors_count -= 1
        file_seed.save!
        return true
      end
    end
    false
  end

  # 检查是否拥有某个权限
  def has_edit_role?(name, resource)
    return false if resource.nil?
    return false unless file_seed = get_file_seed(resource)
    role = all_edit_roles_with_del.find_by(file_seed_id: file_seed.id, name: name)
    role ? true : false
  end

  # 查询权限
  def find_edit_role(resource)
    return nil if resource.nil?
    return nil unless file_seed = get_file_seed(resource)
    role = all_edit_roles_with_del.find_by(file_seed_id: file_seed.id)
    role ? role.name : nil
  end

  # 定义编辑权限, 传入动作和文件, 判断是否允许操作, 返回boolean
  def can_edit?(action, resource)
    return false if action.nil? || resource.nil?
    role = find_edit_role resource # 获取权限
    allow_actions = role.nil? ? nil : Index::Role::Edit.allow_actions(role)
    allow_actions.nil? ? false : allow_actions.include?(action)
  end

  # ------------------------判断赞------------------------- #
  def has_thumb_up?(resource)
    Index::ThumbUp.has?(resource, self)
  end

  # ------------------------标星文件------------------------- #
  def marked_files
    mark_records = self.mark_records.includes(:file)
    marked_files = []
    mark_records.each do |m|
        marked_files << m.file if m.file
    end
    marked_files
  end

  def update_cache
    Cache.new["user_#{self.id}"] = self
  end

  private

  def get_file_seed(resource)
    resource.itself.class.name == 'Index::Workspace::FileSeed' ? resource : resource.file_seed
  end
end
