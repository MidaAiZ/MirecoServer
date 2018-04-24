class ArtReadWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'art_read'

  def perform(id, prefix)
    $redis.select 3
    article = Index::PublishedArticle.all_state.find(id)
    times = (article.read_times_cache) + $redis.SCARD(prefix)
    ApplicationRecord.transaction do
      article.update! read_times_cache: times
      update_corpus_read_times! article
    end

    $redis.del prefix
  # rescue => e
  #   $redis.del prefix
  #   puts e
  #   # TODO 生成报错日志
  end

  private

  def update_corpus_read_times! article
    corpus = article.corpus
    if corpus
      corpus.update! read_times_cache: corpus.cal_read_times
    end
  end
end
