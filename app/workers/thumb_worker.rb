class ThumbWorker
  include Sidekiq::Worker

  def perform(type, id, prefix, temp_prefix)
    init type, id, prefix, temp_prefix
    @thumb_up.thumbs.each do |t| # t: [1, '2017-01-01']
      $redis.HSET(prefix, t[0], t[1])
    end
    set_thumb # 将临时缓存保存到点赞数据缓存中
    $redis.EXPIRE prefix, 10.days.to_i # 无更新时热数据缓存10天后删除
    # 监听点赞频率判断是否可以删除缓存或者将数据保存值数据库
    AutoThumbWorker.perform_at(3.hours.from_now, @thumb_up.id, prefix)
  rescue => e
    puts e
    $redis.DEL temp_prefix # 确保临时缓存一定会被删除
  end

  private

  def init(type, id, prefix, temp_prefix)
    @type = type; @id = id; @prefix = prefix; @temp_prefix = temp_prefix
    $redis.select 2 # 设置database
    @resource = set_resource
    @thumb_up = @resource.thumb_up || @resource.create_thumb_up
  end

  def set_resource
    case @type.to_s
    when 'articles'
      Index::Workspace::Article.with_deleted.find_by_id @id
    when 'corpuses'
      Index::Workspace::Corpus.with_deleted.find_by_id @id
    when 'comments'
      Index::Comment.find_by_id @id
    when 'replies'
      Index::CommentReply.find_by_id @id
    end
  end

  def set_thumb
    tem_keys = $redis.HKEYS(@temp_prefix) || []
    tem_keys.each do |k|
      val = $redis.HGET(@temp_prefix, k)
      if val == 'del' # 取消赞
        $redis.HDEL(@prefix, k)
      else
        $redis.HSET(@prefix, k, val)
      end
    end
    $redis.DEL @temp_prefix # 添加至内存成功后删除临时缓存
    $redis.HSETNX(@prefix, 'last_time', Time.now) # 第一次创建数据库实例时初始化last_time
  end
end
