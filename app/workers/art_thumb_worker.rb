class ArtThumbWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'art_thumb'

  def perform(id, prefix)
    $redis.select 3
    article = Index::PublishedArticle.all_state.find(id)
    times = (article.thumbs_count_cache) + $redis.SCARD(prefix)
    ApplicationRecord.transaction do
      article.update! thumbs_count_cache: times
      update_corpus_thumbs_count! article
    end

    $redis.del prefix
  # rescue => e
  #   $redis.del prefix
  #   puts e
  #   # TODO 生成报错日志
  end

  private

  def update_corpus_thumbs_count! article
    corpus = article.corpus
    if corpus
      corpus.update! thumbs_count_cache: corpus.cal_thumbs_count
    end
  end
end
