class Index::Workspace::EditComment < ActiveRecord::Base
  belongs_to :user,
             class_name: 'Index::User',
             foreign_key: :user_id

  belongs_to :resource, polymorphic: true

  # -------------------------赞--------------------------- #
  validates :user_id, presence: true
  validates :resource_id, presence: true
  validates :resource_type, presence: true, inclusion: { in: ['Index::Workspace::Article'] }
  validates :hash_key, presence: true, length: { maximum: 32 }
  validates :content, presence: true, length: { minimum: 1, maximum: 255 }
end
