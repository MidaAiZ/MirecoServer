class Index::ArtCmtReply < ApplicationRecord
  after_update :update_cache
  after_destroy :clear_cache

  attr_accessor :is_like # 用来缓存用户是否点赞

  belongs_to :user,
             class_name: 'Index::User',
             foreign_key: :user_id

  belongs_to :comment,
             class_name: 'Index::ArtComment',
             foreign_key: :comment_id

  has_many :likes,
            class_name: 'Index::ArtCmtRplLike',
            foreign_key: :reply_id,
            dependent: :destroy

  validates :content, presence: true, length: { minimum: 1, maximum: 2500 }, allow_blank: false

  #----------------------------域------------------------------
  default_scope { order(id: :DESC) }

  def create u, cmt, text
    return false if self.id
    self.comment = cmt
    self.user = u
    self.content = text
    save
  end

  # 点赞
  def add_like user
    like =  likes.find_by_user_id(user.id) || likes.build
    return true if like.id
    if like.create(user, self)
      add_like_count user.id
      return true
    end
    false
  end

  # 取消赞
  def delete_like user
    like = likes.find_by_user_id user.id
    if like && like.cancel
      minus_like_count user.id
      return true
    end
    false
  end

  def can_be_deleted_by? user
    user.id == user_id ||
    user.id == comment.user_id ||
    user.can_edit?(:comment, comment.article.origin)
  end

  # 点赞数
  def likes_count
    likes_count_cache + $redis.SCARD(like_prefix)
  end

  private
  #
  def cache_prefix
    self.cache_key
  end

  def like_prefix
    "likes_count_#{cache_prefix}".hash
  end

  def add_like_count key
    prefix = like_prefix
    puts ArtCmtRplLikeWorker.perform_at(3.hours.from_now, self.id, prefix) if $redis.EXISTS(prefix) == 0
    $redis.SADD(prefix, key)
  end

  def minus_like_count key # 取消赞是低频操作
    prefix = like_prefix
    if $redis.SISMEMBER prefix, key
      $redis.SREM prefix, key
    else
      t_count = likes_count_cache - 1
      t_count = 0 if t_count < 0
      update likes_count_cache: t_count
    end
  end
end
