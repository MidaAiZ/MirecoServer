class Index::Workspace::EditComment < ApplicationRecord
  after_update :update_cache
  after_destroy :clear_cache

  belongs_to :user,
             class_name: 'Index::User',
             foreign_key: :user_id

  belongs_to :resource, polymorphic: true

  has_many :replies,
            class_name: 'Index::Workspace::EditCommentReply',
            foreign_key: :edit_comment_id

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
end
