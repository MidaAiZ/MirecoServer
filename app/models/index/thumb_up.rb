class Index::ThumbUp < ApplicationRecord
  belongs_to :resource, polymorphic: true

  validates :resource_type, inclusion: { in: ['Index::Workspace::Article', 'Index::Workspace::Corpus', 'Index::Comment', 'Index::CommentReply'] }
  validates :resource_id, presence: true

  #----------------------------域------------------------------
  scope :t_counts, ->{ select(:thumbs_count) }


  #-------------------------- 添加赞 ------------------------#
  def self.add(resource, user)
    prefix(resource)
    init_thumb(resource) if @tmp_prefix
    t = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    $redis.HSET(@prefix, user.id, t) == 1 ? $redis.HSET(@prefix, 'last_time', t) : false
  end

  #-------------------------- 取消赞 ------------------------#
  def self.cancel(resource, user)
    prefix(resource)
    if @tmp_prefix
      init_thumb resource
      $redis.HMSET(@prefix, user.id, 'del', 'last_time', Time.now)
    else
      result = $redis.HDEL(@prefix, user.id) == 1 ? true : false
      $redis.HSET(@prefix, 'last_time', Time.now) if result
    end
  end

  #-------------------------- 获取赞 ------------------------#
  def self.get(resource)
    prefix(resource)
    if @tmp_prefix
      set_thumbs(resource)
    else
      to_hash($redis.HGETALL @prefix)
    end
  end

  #-------------------------- 判断赞 ------------------------#
  def self.has?(resource, user)
    prefix(resource)
    if @tmp_prefix
      set_thumbs(resource).include? user.id.to_s
    else
      $redis.HEXISTS(@prefix, user.id) == 1 ? true : false
    end
  end

  #-------------------------- 点赞数 ------------------------#
  def self.counts(resource)
    prefix(resource)
    if @tmp_prefix
      resource.tbp_counts || 0
    else
      $redis.HLEN(@prefix) - 1
    end
  end

  def self.counts_and_has?(resource, user)
      prefix(resource)
      if @tmp_prefix
        thumbs = set_thumbs(resource)
        counts = thumbs.size
        has = user ? thumbs.include?(user.id.to_s) : false
      else
        counts = $redis.HLEN(@prefix) - 1
        has = $redis.HEXISTS(@prefix, (user ? user.id : nil)) == 1 ? true : false
      end
      { counts: counts, has: has }
  end

  private

  def self.prefix resource
    $redis.select 2 # 设置database
    @prefix = "index_#{resource.id}_#{resource.file_type}_thumbs"
    @tmp_prefix = nil
    $redis.EXISTS(@prefix)
    if $redis.EXISTS(@prefix) == 0
       @tmp_prefix = 'tmp_' + @prefix
    end
  end

  def self.init_thumb resource
    if $redis.EXISTS(@tmp_prefix) == 0 # 判断是否已经进行异步加载
      ThumbWorker.perform_async(resource.file_type, resource.id, @prefix, @tmp_prefix)
    end
    @prefix = @tmp_prefix
  end

  def self.set_thumbs resource
    counts = resource.tbp_counts || 0
    if counts > 0 && counts < 10000
      resource.thumb_up.thumbs.merge(to_hash($redis.HGETALL(@tmp_prefix)))
    else
      to_hash $redis.HGETALL(@tmp_prefix)
    end
  end

  def self.to_hash(arr = []) # 由于zz的redis hash数据返回的是数组，需要将数组转化为hash
    i = 0; len = arr.size; hash = {}
    while i < len
      hash[arr[i]] = arr[i + 1] if arr[i + 1] != 'del'
      i += 2
    end
    hash.delete 'last_time'
    hash
  end
end
