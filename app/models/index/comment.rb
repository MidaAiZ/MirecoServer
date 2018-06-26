class Index::Comment < ApplicationRecord
  after_update :update_cache
  after_destroy :delete_like, :clear_cache

  store_accessor :info, :tbp_counts, :rep_counts, :read_times # 点赞数/回复数/阅读次数

  belongs_to :user,
             class_name: 'Index::User',
             foreign_key: :user_id

  belongs_to :resource, polymorphic: true

  has_many :replies,
           class_name: 'Index::CommentReply',
           dependent: :destroy

  has_many :limit_3_replies, -> { limit(3) },
           class_name: 'Index::CommentReply'

  # -------------------------赞--------------------------- #
  has_one :like, as: :resource,
                     class_name: 'Index::Like',
                     dependent: :destroy

  has_one :like_ct, -> { t_counts },
          as: :resource,
          class_name: 'Index::Like'

  # -------------------------验证------------------------- #

  validates :user_id, presence: true
  validates :resource_id, presence: true
  validates :resource_type, presence: true, inclusion: { in: ['Index::PublishedArticle', 'Index::PublishedCorpus'] }
  validates :content, presence: true, length: { minimum: 1, maximum: 255 }, allow_blank: false

  #----------------------------域------------------------------
  default_scope { order(id: :DESC) }

  # ------------------------文件类型------------------------- #
  def file_type
    :comments
  end

  def create rsc, u, text
    return false if self.id

    self.resource = rsc
    self.user = u
    self.content = text

    save
  end

  def remove rsc
    return destroy
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

  def update_cache
    Cache.new["comment_#{self.id}"] = self
  end

  def clear_cache
    Cache.new["comment_#{self.id}"] = nil
  end
end
