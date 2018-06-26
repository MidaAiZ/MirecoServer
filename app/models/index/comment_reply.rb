class Index::CommentReply < ApplicationRecord
  after_destroy :delete_like, :clear_cache
  store_accessor :info, :tbp_counts, :read_times # 点赞数/阅读次数

  belongs_to :user,
             class_name: 'Index::User',
             foreign_key: :user_id

  belongs_to :comment,
             class_name: 'Index::Comment',
             foreign_key: :comment_id

  # -------------------------赞--------------------------- #
  has_one :like, as: :resource,
                     class_name: 'Index::Like',
                     dependent: :destroy

  has_one :like_ct, -> { t_counts },
          as: :resource,
          class_name: 'Index::Like'

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
  def like user
    Index::Like.add self, user
  end

  # ------------------------取消赞------------------------- #
  def cancel_like user
    Index::Like.cancel self, user
  end

  # --------------------------赞--------------------------- #
  def likes
    Index::Like.get(self)
  end

  # -------------------------赞数-------------------------- #
  def like_counts
    Index::Like.counts(self)
  end

  # ------------------------判断赞------------------------- #
  def has_like?(user)
    Index::Like.has?(self, user)
  end

  # -----------------------点赞信息------------------------ #
  def like_info(user)
    Index::Like.counts_and_has?(self, user)
  end

  def delete_like
    # Index::Like.destroy self
  end

  def clear_cache
    Cache.new["reply_#{self.id}"] = nil
  end
end
