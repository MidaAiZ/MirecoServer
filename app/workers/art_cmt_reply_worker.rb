class ArtCmtReplyWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'art_comment'

  def perform(id, prefix)
    comment = Index::ArtComment.find_by_id(id)
    if comment
      count = (comment.replies_count_cache) + $redis.SCARD(prefix)
      comment.update! replies_count_cache: count
    end
    $redis.del prefix
  # rescue => e
  #   $redis.del prefix
  #   puts e
  #   # TODO 生成报错日志
  end

end
