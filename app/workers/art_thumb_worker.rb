class ArtThumbWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'thumb_count'

  def perform(id, prefix)
    $redis.select 3
    article = Index::PublishedArticle.find(id)
    times = (article.thumbs_count_cache) + $redis.SCARD(prefix) 
    article.update! thumbs_count_cache: times
    update_corpus_read_times

    $redis.del prefix
  rescue => e
    $redis.del prefix
    puts e
    # TODO 生成报错日志
  end

  private

  def update_corpus_read_times
    corpus = article.corpus
    if corpus
      corpus.update! thumbs_count_cache: corpus.cal_thumbs_count
    end
  end
end
