class Index::CommentReply < ApplicationRecord
  after_destroy :delete_thumb_up, :clear_cache
  store_accessor :info, :tbp_counts, :read_times # 点赞数/阅读次数

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

  has_one :thumb_ct, -> { t_counts },
          as: :resource,
          class_name: 'Index::ThumbUp'

  # -------------------------验证------------------------- #

  validates :user_id, presence: true
  validates :comment_id, presence: true
  validates :content, presence: true, length: { minimum: 1, maximum: 255 }

  #----------------------------域------------------------------
  default_scope { order('index_comment_replies.id DESC') }

  def create cmt, user
    return false if self.id

    ApplicationRecord.transaction do
      self.comment = cmt
      self.user = user
      self.save!
      cmt.update! rep_counts: (cmt.rep_counts || 0) + 1
    end
  end

  def drop cmt
    ApplicationRecord.transaction do
      self.destroy!
      cmt.update! rep_counts: (cmt.rep_counts || 0) - 1
    end
  end

  # ------------------------文件类型------------------------- #
  def file_type
    :replies
  end

  # -------------------------点赞-------------------------- #
  def thumb_up user
    Index::ThumbUp.add self, user
  end

  # ------------------------取消赞------------------------- #
  def thumb_cancel user
    Index::ThumbUp.cancel self, user
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

  # -----------------------点赞信息------------------------ #
  def thumb_up_info(user)
    Index::ThumbUp.counts_and_has?(self, user)
  end

  def delete_thumb_up
    # Index::ThumbUp.destroy self
  end

  def clear_cache
    Cache.new["reply_#{self.id}"] = nil
  end
end
