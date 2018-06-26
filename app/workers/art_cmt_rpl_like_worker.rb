class ArtCmtRplLikeWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'art_like'

  def perform(id, prefix)
    rpl = Index::ArtCmtReply.find_by_id(id)
    if rpl
      times = (rpl.likes_count_cache) + $redis.SCARD(prefix)
      rpl.update! likes_count_cache: times
    end

    $redis.del prefix
  # rescue => e
  #   $redis.del prefix
  #   puts e
  #   # TODO 生成报错日志
  end

  private

end
