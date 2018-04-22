class ArtReadWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'read_times'

  def perform(id, prefix)
    $redis.select 3
    article = Index::PublishedArticle.find(id)
    times = (article.read_times_cache) + $redis.SCARD(prefix) 
    article.update! read_times_cache: times
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
      corpus.update! read_times_cache: corpus.cal_read_times
    end
  end
end
