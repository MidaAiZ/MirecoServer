class Index::Workspace::EditComment < ApplicationRecord
  after_update :update_cache
  after_destroy :clear_cache

  belongs_to :user,
             class_name: 'Index::User',
             foreign_key: :user_id

  belongs_to :resource, polymorphic: true

  # -------------------------赞--------------------------- #
  validates :user_id, presence: true
  validates :resource_id, presence: true
  validates :resource_type, presence: true, inclusion: { in: ['Index::Workspace::Article'] }
  validates :hash_key, presence: true, length: { maximum: 32 }, uniqueness: { message: 'hash值已存在' }
  validates :content, presence: true, length: { minimum: 1, maximum: 255 }

  def update_cache
    Cache.new["edit_comment_#{self.id}"] = self
  end

  def clear_cache
    Cache.new["edit_comment_#{self.id}"] = nil
  end

  def self.include_users edit_comments = []
    ids = Set.new
    edit_comments.each do |co|
      co.replies.each_value do |re|
        ids.add re['user_id']
      end
    end
    users = {}
    _users = Index::User.where(id: ids.to_a).brief
    _users.each do |u|
      users[u.id] = u
    end
    edit_comments.each do |co|
      co.replies.each_value do |re|
        re[:user] = users[re['user_id']]
      end
    end
  end
end
