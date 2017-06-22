class Index::Comment < ActiveRecord::Base
  after_destroy :delete_thumb_up

  belongs_to :user,
             class_name: 'Index::User',
             foreign_key: :user_id

  belongs_to :resource, polymorphic: true

  has_many :replies,
           class_name: 'Index::CommentReply',
           dependent: :destroy

  # -------------------------赞--------------------------- #
  has_one :thumb_up, as: :resource,
                     class_name: 'Index::ThumbUp',
                     dependent: :destroy

  has_one :thumb_ct, -> { t_counts },
          as: :resource,
          class_name: 'Index::ThumbUp'

  # -------------------------验证------------------------- #

  validates :user_id, presence: true
  validates :resource_id, presence: true
  validates :resource_type, presence: true, inclusion: { in: ['Index::Workspace::Article', 'Index::Workspace::Corpus'] }
  validates :content, presence: true, length: { minimum: 1, maximum: 255 }

  # ------------------------文件类型------------------------- #
  def file_type
    :comments
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

  def delete_thumb_up
    # Index::ThumbUp.destroy self
  end
end
