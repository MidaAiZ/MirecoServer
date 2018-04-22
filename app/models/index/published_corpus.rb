class Index::PublishedCorpus < ApplicationRecord
  mount_uploader :cover, FileCoverUploader # 封面上传

  belongs_to :origin, -> { with_del },
             class_name: 'Index::Workspace::Corpus',
             foreign_key: :origin_id

  # ---------------------作者和作者角色---------------------- #
  belongs_to :author,
             class_name: 'Index::User',
             foreign_key: :user_id

  has_many :articles,
           class_name: 'Index::PublishedArticle',
           foreign_key: :corpus_id,
           dependent: :destroy

  has_many :editor_roles,
           through: :origin,
           source: :editor_roles

  has_many :editors,
           through: :origin,
           source: :editors

  # -------------------------赞--------------------------- #
  has_many :thumbs,
           through: :articles,
           source: :thumbs

  # ------------------------评论-------------------------- #
  has_many :comments,
            through: :articles,
            source: :comments

  # -----------------------浏览记录----------------------- #
  has_many :read_records,
            through: :articles,
            source: :read_records

 # ------------------------------------------------------ #
 # ---------------------华丽丽的分割线--------------------- #

  # 数据验证
  validates :tag, length: { maximum: 25 }

  #--------------------------状态模型---------------------------
  enum state: [:deleted, :released, :reviewing, :forbidden]

  #----------------------------域------------------------------

  scope :filter, ->(tag) { where('tag LIKE ?', "%#{tag}") }
  scope :all_state, -> { unscope(where: :state) }
  scope :deleted, -> { unscope(where: :state).where(state: states[:deleted]) }
  scope :forbidden, -> { unscope(where: :state).where(state: states[:forbidden]) }
  scope :released, -> { unscope(where: :state).where(state: states[:released]) }
  scope :in_review, -> { unscope(where: :state).where(state: states[:deleted]) }
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
    ApplicationRecord.transaction do
      update state: self.class.states[:reviewing]
      articles.each do |a|
        a.review
      end
    end
  end

  def release
    return false if forbidden? || released?
    ApplicationRecord.transaction do
      update state: self.class.states[:released]
      articles.each do |a|
        a.release
      end
    end
  end

  def delete
    return false if forbidden? || deleted?
    ApplicationRecord.transaction do
      update state: self.class.states[:deleted]
      articles.each do |a|
        a.delete
      end
    end
  end

  def forbid
    return false if deleted? || forbidden?
    ApplicationRecord.transaction do
      update state: self.class.states[:forbidden]
      articles.each do |a|
        a.forbid
      end
    end
  end

  def toggle_delete bool
    bool ? self.delete : self.release
  end

  # -------------------------信息统计------------------------- #
  # 阅读次数
  def read_times
    Rails.cache.fetch(comment_prefix, expires_in: 15.minutes) do
      cal_read_times
    end
  end

  # 评论数
  def comments_count
    Rails.cache.fetch(read_prefix, expires_in: 15.minutes) do
      cal_comments_count
    end
  end

  # 点赞数
  def thumbs_count
    Rails.cache.fetch(thumb_prefix, expires_in: 15.minutes) do
      cal_thumbs_count
    end
  end

  # -------------------------统计计算------------------------- #
  def cal_read_times
    articles.sum(:read_times_cache)
  end

  def cal_comments_count
    articles.sum(:comments_count_cache)
  end

  def cal_thumbs_count
    articles.sum(:thumbs_count_cache)
  end

  # 禁止删除
  def destroy
    return false
  end

  private
  #
  def cache_prefix
    $redis.select 3
    "#{self.id}_corp_release"
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
end
