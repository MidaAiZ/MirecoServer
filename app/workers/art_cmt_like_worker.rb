class ArtCmtLikeWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'art_like'

  def perform(id, prefix)
    cmt = Index::ArtComment.find_by_id(id)
    if cmt
      times = (cmt.likes_count_cache) + $redis.SCARD(prefix)
      cmt.update! likes_count_cache: times
    end
    $redis.del prefix
  # rescue => e
  #   $redis.del prefix
  #   puts e
  #   # TODO 生成报错日志
  end

  private

end
