class ArtContentWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'art_content'

  def perform(id, key)
    cache = Index::Workspace::ArticleContent.fetch(id)
    if (cache) # 防止用户已经将内容删除
      cache.save!
      cache.clear_cache
    end
    $redis.DEL key

  # rescue => e
  #   $redis.del prefix
  #   puts e
  #   # TODO 生成报错日志
  end
end
