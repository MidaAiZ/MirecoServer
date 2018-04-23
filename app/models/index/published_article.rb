class Index::PublishedArticle < ApplicationRecord
  mount_uploader :cover, FileCoverUploader # 封面上传

  # store_accessor :info, :tbp_counts, :cmt_counts, :rd_times # 点赞数/评论数/阅读次数

  # -----------------------文章内容------------------------ #
  belongs_to :content,
          class_name: 'Index::Workspace::ArticleContent',
          foreign_key: :content_id

  belongs_to :origin,
             class_name: 'Index::Workspace::Article',
             foreign_key: :origin_id,
             optional: true

  belongs_to :corpus, -> { with_del },
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
  has_many :comments, as: :resource,
                      class_name: 'Index::Comment',
                      dependent: :destroy

  # -------------------------赞--------------------------- #
  has_many :thumbs,
           class_name: 'Index::ArticleThumbUp',
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

  def toggle_delete bool
    bool ? self.delete : self.release
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
  def thumbs_count
    thumbs_count_cache + $redis.SCARD(thumb_prefix)
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
  def thumb_up user
    thumb =  thumbs.find_by_user_id(user.id) || thumbs.build
    return true if thumb.id
    if thumb.create(user)
      add_thumb_count user.id
      return true
    end
  end

  # 取消赞
  def thumb_cancel user
    thumb = thumbs.find_by_user_id user.id
    if thumb && thumb.cancel
      reduce_thumb_count user.id
      return true
    end
  end

  # 评论
  def comment user, content
     cmt = comments.build
     if cmt.create(self, user, content)
       add_comments_count cmt.id
     end
     return cmt
  end

  # 删除评论
  def delete_comment cmt
    return if (cmt.resource_id != self.id)
    if cmt.remove(self)
      reduce_thumb_count cmt.id
      return true
    end
  end

  # 禁止删除
  def destroy
    return false
  end

  private
  #
  def cache_prefix
    $redis.select 3
    "#{self.id}_art_release"
  end

  def read_prefix
    cache_prefix + "_read"
  end

  def comment_prefix
    cache_prefix + "_cmt"
  end

  def thumb_prefix
    cache_prefix + "_thumb"
  end

  def add_thumb_count key
    prefix = thumb_prefix
    puts ArtThumbWorker.perform_at(3.hours.from_now, self.id, prefix) if $redis.EXISTS(prefix) == 0
    $redis.SADD(prefix, key)
  end

  def reduce_thumb_count key # 取消赞是低频操作
    prefix = thumb_prefix
    if $redis.SISMEMBER prefix, key
      $redis.SREM prefix, key
    else
      t_count = thumbs_count_cache - 1
      t_count = 0 if t_count < 0
      update thumbs_count_cache: t_count
    end
  end

  def add_comments_count key
    prefix = comment_prefix
    puts ArtCommentWorker.perform_at(3.hours.from_now, self.id, prefix) if $redis.EXISTS(prefix) == 0
    $redis.SADD(prefix, key)
  end

  def reduce_comment_count key
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
