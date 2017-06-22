class Index::CommentReply < ActiveRecord::Base
  after_destroy :delete_thumb_up

  belongs_to :user,
             class_name: 'Index::User',
             foreign_key: :user_id

  belongs_to :comment,
             class_name: 'Index::Comment',
             foreign_key: :comment_id

  # -------------------------赞--------------------------- #
  has_one :thumb_up, as: :resource,
                     class_name: 'Index::ThumbUp',
                     dependent: :destroy

  validates :user_id, presence: true
  validates :comment_id, presence: true
  validates :content, presence: true, length: { minimum: 1, maximum: 255 }

  # ------------------------文件类型------------------------- #
  def file_type
    :replies
  end

  # --------------------------赞--------------------------- #
  def thumb_up
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
    Index::ThumbUp.destroy self
  end
end
