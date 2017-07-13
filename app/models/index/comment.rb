class Index::Comment < ApplicationRecord
  after_update :update_cache
  after_destroy :delete_thumb_up, :clear_cache

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

  #----------------------------域------------------------------
  default_scope { order('index_comments.id DESC') }

  # ------------------------文件类型------------------------- #
  def file_type
    :comments
  end

  def create rsc, user
    ApplicationRecord.transaction do
      self.resource = rsc
      self.user = user
      self.save!
      rsc.update! cmt_counts: (rsc.cmt_counts || 0) + 1
    end
  end

  def drop rsc
    ApplicationRecord.transaction do
      self.destroy!
      rsc.update! cmt_counts: (rsc.cmt_counts || 0) - 1
    end
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

  def update_cache
    Cache.new["comment_#{self.id}"] = self
  end

  def clear_cache
    Cache.new["comment_#{self.id}"] = nil
  end
end
