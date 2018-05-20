class SocketArtContentWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'socket_art_content'

  def perform(id, uid, changes)
    artCache = Index::Workspace::Article.fetch(id)
    if (artCache) # 防止用户已经将内容删除
      contentCache = Index::Workspace::ArticleContent.fetch(artCache.content_id)
      textCache = Index::Workspace::Article.fetch_text(id)
      if contentCache && textCache
        contentCache.update_text textCache
        artCache.add_history(uid, changes, textCache) if (changes)
      end
    end

  # rescue => e
  #   $redis.del prefix
  #   puts e
  #   # TODO 生成报错日志
  end
end
