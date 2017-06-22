class AutoThumbWorker
  include Sidekiq::Worker

  def perform(id, prefix)
    init id, prefix
    last_time = Time.parse($redis.HGET(prefix, 'last_time') || @thumb.updated_at.to_s) # 最后点赞时间
    last_update = @thumb.updated_at # 最后保存时间
    interval = (Time.now - last_time) # 离最近一次点赞的间隔
    if last_time > last_update # 判断在写入缓存后是否有更新，有则保存，无则判断删除
      auto_save interval
    else
      return if $redis.EXISTS(prefix) == 0 # 无更新时热数据缓存10天, 被删除后不再监听
    end
    AutoThumbWorker.perform_at(5.hours.from_now, id, prefix) if @thumb # 五小时后再判断自动保存
  rescue => e
    # 存在一种情况，在异步保存点赞数据时原文章等已被作者删除
    puts e
    $redis.DEL prefix unless @thumb
    # TODO: 记录出错异常,生成报错信息提交给后台管理员
  end

  private

  def init(id, prefix)
    @id = id; @prefix = prefix
    $redis.select 2 # 选择database
    @thumb = Index::ThumbUp.find @id
  end

  def auto_save(interval)
    len = $redis.HLEN @prefix
    # 根据数据量的大小分为5个等级，根据不同的等级判断是否需要保存
    # 数据量越大，保存时消耗越大，故保存的间隔越久
    if len < 1000
      save
    elsif len < 10_000
      save if interval > 3.hours.to_i
    elsif len < 100_000
      save if interval > 1.days.to_i
    elsif len < 500_000
      save if interval > 3.days.to_i
    else
      save if interval > 5.days.to_i
    end
  end

  def save
    t = Time.now
    if $redis.HLEN(@prefix) == 1 # 没有人点赞时(唯一key为:last_time)删除thumb_up
      @thumb.delete
      $redis.DEL @prefix
      @thumb = nil
    else
      @thumb.update! thumbs: to_hash($redis.HGETALL(@prefix)), thumbs_count: $redis.hlen(@prefix) - 1
      $redis.EXPIRE @prefix, 10.days.to_i # 每次更新将数据的生命期重置为10天
    end
    puts '时间消耗----------------------------------------'
    puts Time.now - t
  end

  def to_hash(arr = []) # 由于zz的redis hash数据返回的是数组，需要将数组转化为hash
    t1 = Time.now
    i = 0; len = arr.size; hash = {}
    while i < len
      hash[arr[i]] = arr[i + 1]
      i += 2
    end
    puts '时间消耗hash--------------------------------------'
    puts Time.now - t1
    hash
  end
end
