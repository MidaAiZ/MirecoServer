class Index::Role::Edit < ApplicationRecord
  belongs_to :editor,
             class_name: 'Index::User',
             foreign_key: 'user_id'

  belongs_to :file_seed,
             class_name: 'Index::Workspace::FileSeed',
             foreign_key: 'file_seed_id'

  belongs_to :dir, polymorphic: true,
             optional: true

  has_one :root_file,
           through: :file_seed,
           source: :root_file

  validates :file_seed_id, presence: true
  validates :name, inclusion: { in: %w(own admin editor readonly) }

  #----------------------------域------------------------------
  scope :own, -> { where(name: :own).first }
  scope :root, -> { where(dir_id: nil) }
  scope :all_dir, -> { unscope(where: :dir_id) }
  scope :deleted, -> { rewhere(is_deleted: true) }
  scope :undeleted, -> { rewhere(is_deleted: false) }
  scope :all_with_del, -> { all_dir.unscope(where: :is_deleted) }

  default_scope -> { root.undeleted.order(id: :DESC) }

  def self.allow_actions(role)
    ROLES[role]
  end

  def self.allow_roles
    %w(admin editor readonly)
  end

  def is_root?
    !dir_id
  end

  def is_author?
    name == 'own'
  end

  private

  # 定义权限
  ROLES = {
    'own' => [:all, :read, :create, :edit, :update, :delete, :destroy, :comment, :delete_comment, :move_dir, :add_history, :add_role, :remove_role, :publish, :copy], # 拥有者, 具有所有权限
    'admin' => [:read, :create, :edit, :update, :delete, :comment, :delete_comment, :move_dir, :add_history, :add_role, :remove_role],
    'editor' => [:read, :edit, :comment, :add_history],
    'readonly' => [:read]
  }.freeze
end

# 合理的查询关联加载方案
# 尝试1: as = Index::User.last.articles.includes(users: :roles).limit(10)
# 尝试2: as = Index::User.last.roles(Index::Workspace::Article).includes(users: :roles)
# 尝试3: Index::Workspace::Article.with_roles(:own, u).includes(roles: :users)
#
# 尝试4: 用户自己的文章+协作的文章, 目前的最有查询方法
# rs = u.roles.where(resource_type: "Index::Workspace::Article").includes(resource: {roles: :users})
# r = rs[0]
# r.resource.roles[0].users
#
# 尝试5: 属于用户自己的文章, 目前的最优查询方法
# Index::Workspace::Article.find_roles(:own, u).includes(resource: {roles: :users})
# 在100个以内的数据库查询时间消耗可以忽略, 加载时应预加载相关资源
