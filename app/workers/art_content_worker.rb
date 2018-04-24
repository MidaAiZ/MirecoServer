class ArtContentWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'art_content'

  def perform(id, key)
    origin = Index::Workspace::ArticleContent.find_by_id(id)
    if (origin) # 防止用户已经将内容删除
       cache = Index::Workspace::ArticleContent.fetch(id)
       cache.save!
    end

    $redis.DEL key
  # rescue => e
  #   $redis.del prefix
  #   puts e
  #   # TODO 生成报错日志
  end
end
