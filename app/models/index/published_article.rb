class Index::PublishedArticle < ApplicationRecord
  # mount_uploader :cover, FileCoverUploader # 封面上传

  # store_accessor :info, :tbp_counts, :cmt_counts, :rd_times # 点赞数/评论数/阅读次数
  attr_accessor :is_like # 用来缓存用户是否点赞
  
  after_update :update_cache
  after_destroy :clear_cache

  # -----------------------文章内容------------------------ #
  belongs_to :inner_content,
          class_name: 'Index::Workspace::ArticleContent',
          foreign_key: :content_id

  belongs_to :origin, -> { with_del },
             class_name: 'Index::Workspace::Article',
             foreign_key: :origin_id,
             optional: true

  belongs_to :corpus, -> { all_state },
             class_name: 'Index::PublishedCorpus',
             foreign_key: :corpus_id,
             optional: true

  # ---------------------作者和作者角色---------------------- #
  belongs_to :author,
             class_name: 'Index::User',
             foreign_key: :user_id

  has_many :editor_roles,
           through: :origin,
           source: :editor_roles

  has_many :editors,
           through: :origin,
           source: :editors

  # -----------------------读者评论------------------------ #
  has_many :comments,
           class_name: 'Index::ArtComment',
           foreign_key: :article_id,
           dependent: :destroy

  # -------------------------赞--------------------------- #
  has_many :likes,
           class_name: 'Index::ArticleLike',
           foreign_key: :article_id,
           dependent: :destroy

  # ----------------------浏览记录------------------------ #
  has_many :read_records,
           class_name: 'Index::ArticleReadRecord',
           foreign_key: :article_id

 # ------------------------------------------------------ #
 # ---------------------华丽丽的分割线--------------------- #

  # 数据验证
  validates :tag, length: { maximum: 25 }
  validates :origin_id, uniqueness: true
  validate :check_origin, on: [:create]

  #--------------------------状态模型---------------------------
  enum state: [:deleted, :released, :reviewing, :forbidden]

  #----------------------------域------------------------------

  scope :filter, ->(tag) { where('tag LIKE ?', "%#{tag}") }
  scope :all_state, -> { unscope(where: :state) }
  scope :deleted, -> { unscope(where: :state).where(state: states[:deleted]) }
  scope :forbidden, -> { unscope(where: :state).where(state: states[:forbidden]) }
  scope :released, -> { unscope(where: :state).where(state: states[:released]) }
  scope :reviewing, -> { unscope(where: :state).where(state: states[:deleted]) }
  scope :hot, -> { reorder('(read_times_cache + 0.1) / (CURRENT_DATE - date(created_at) + 1) DESC').order(id: :DESC) }
  scope :recommend, -> { reorder('(|/id + 0.01 * read_times_cache) DESC').order(id: :DESC) }
  # 默认作用域, 不包含content字段, id降序, 未删除的文章
  default_scope { released.order(id: :DESC) }

  def file_type
    :articles
  end

  #  query state
  def deleted?
    state == 'deleted'
  end

  def in_review?
    state == 'reviewing'
  end

  def released?
    state == 'released'
  end

  def forbidden?
    state == 'forbidden'
  end

  # set state
  def review
    return false if deleted?
    update state: :reviewing
  end

  def release
    return false if forbidden? || released?
    update state: :released
  end

  def delete
    return false if forbidden? || deleted?
    update state: :deleted
  end

  def forbid
    return false if deleted? || forbidden?
    update state: :forbidden
  end

  # -------------------------文章内容------------------------- #
  def content
    Index::Workspace::ArticleContent.fetch(content_id)
  end

  # -------------------------信息统计------------------------- #
  # 阅读次数
  def read_times
    read_times_cache + $redis.SCARD(read_prefix)
  end

  # 评论数
  def comments_count
    comments_count_cache + $redis.SCARD(comment_prefix)
  end

  # 点赞数
  def likes_count
    likes_count_cache + $redis.SCARD(like_prefix)
  end

  # -------------------------用户操作------------------------- #
  # 浏览
  def read ip, user
    record = read_records.find_by_user_id(user.id) || read_records.build
    if !record.id && record.create(ip, user)
      add_read_times user ? user.id : ip
      return true
    end
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

  # 评论
  def comment user, content
     cmt = comments.build
     if cmt.create(user, self, content)
       add_comments_count cmt.id
     end
     cmt
  end

  # 删除评论
  def delete_comment cmt
    return if (cmt.article_id != self.id)
    if cmt.destroy
      minus_comment_count cmt.id
      return true
    end
  end

  # 禁止删除
  # def destroy
  #   errors.add(:base, "forbid to destroy the resource")
  #   return false
  # end

  private
  #
  def cache_prefix
    self.cache_key
  end

  def read_prefix
    "read_times_#{cache_prefix}".hash
  end

  def comment_prefix
    "cmts_count_#{cache_prefix}".hash
  end

  def like_prefix
    "likes_count_#{cache_prefix}".hash
  end

  def add_like_count key
    prefix = like_prefix
    puts ArtLikeWorker.perform_at(3.hours.from_now, self.id, prefix) if $redis.EXISTS(prefix) == 0
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

  def add_comments_count key
    prefix = comment_prefix
    puts ArtCommentWorker.perform_at(3.hours.from_now, self.id, prefix) if $redis.EXISTS(prefix) == 0
    $redis.SADD(prefix, key)
  end

  def minus_comment_count key
    prefix = comment_prefix
    if $redis.SISMEMBER prefix, key
      $redis.SREM prefix, key
    else
      c_count = comments_count_cache - 1
      c_count = 0 if c_count < 0
      update comments_count_cache: c_count
    end
  end

  # -------------------------添加阅读次数------------------------- #
  def add_read_times key
    prefix = read_prefix
    puts ArtReadWorker.perform_at(3.hours.from_now, self.id, prefix) if $redis.EXISTS(prefix) == 0
    $redis.SADD(prefix, key)
  end

  def check_origin
    errors.add(:origin, '源文章必须存在') if !origin
  end
end
