class Index::ThumbUp < ActiveRecord::Base
  belongs_to :resource, polymorphic: true

  validates :resource_type, inclusion: { in: ['Index::Workspace::Article', 'Index::Workspace::Corpus', 'Index::Comment', 'Index::CommentReply'] }
  validates :resource_id, presence: true

  #----------------------------域------------------------------
  scope :t_counts, ->{ select(:thumbs_count) }


  #-------------------------- 添加赞 ------------------------#
  def self.add(resource, user)
    t = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    $redis.HMSET(prefix(resource), user.id, t, 'last_time', t)
  end

  #-------------------------- 取消赞 ------------------------#
  def self.cancel(resource, user)
    prefix = prefix(resource)
    if prefix.index 'temp'
      $redis.HMSET(prefix, user.id, 'del', 'last_time', Time.now)
    else
      result = $redis.HDEL(prefix, user.id) == 1 ? true : false
      $redis.HSET(prefix, 'last_time', Time.now) if result
    end
  end

  #-------------------------- 获取赞 ------------------------#
  def self.get(resource)
    prefix = prefix(resource)
    if prefix.index 'temp'
      set_thumbs(resource, prefix)
    else
      to_hash($redis.HGETALL prefix)
    end
  end

  #-------------------------- 判断赞 ------------------------#
  def self.has?(resource, user)
    prefix = prefix(resource)
    if prefix.index 'temp'
      set_thumbs(resource, prefix).include? user.id.to_s
    else
      $redis.HEXISTS(prefix, user.id) == 1 ? true : false
    end
  end

  #-------------------------- 点赞数 ------------------------#
  def self.counts(resource)
    prefix = prefix(resource)
    if prefix.index 'temp'
      $redis.HLEN(prefix) + ((resource.thumb_ct.thumbs_count if resource.thumb_ct) || 0)
    else
      $redis.HLEN(prefix) - 1
    end
  end

  private

  def self.prefix(resource)
    return nil if resource.nil?
    $redis.select 2 # 设置database
    prefix = "index_thumbs_#{resource.file_type}_#{resource.id}"
    if $redis.EXISTS(prefix) == 1
      prefix
    else # 异步加载点赞数据, 可以承受百万级别的高并发或点赞数
      tem_pre = 'temp_' + prefix
      if $redis.EXISTS(tem_pre) == 0 # 判断是否已经进行异步加载
        ThumbWorker.perform_async(resource.file_type, resource.id, prefix, tem_pre)
      end
      tem_pre
    end
  end

  def self.set_thumbs resource, prefix
    counts = resource.thumb_ct.thumbs_count if resource.thumb_ct
    counts && counts < 1000 ? resource.thumb_up.thumbs.merge(to_hash($redis.HGETALL(prefix))) : $redis.HGETALL(prefix)
  end

  def self.to_hash(arr = []) # 由于zz的redis hash数据返回的是数组，需要将数组转化为hash
    i = 0; len = arr.size; hash = {}
    while i < len
      hash[arr[i]] = arr[i + 1]
      i += 2
    end
    hash
  end
end
