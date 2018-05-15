class ArtCommentWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'art_comment'

  def perform(id, prefix)
    article = Index::PublishedArticle.all_state.find(id)
    times = (article.comments_count_cache) + $redis.SCARD(prefix)
    ApplicationRecord.transaction do
      article.update! comments_count_cache: times
      update_corpus_comments_count! article
    end

    $redis.del prefix
  # rescue => e
  #   $redis.del prefix
  #   puts e
  #   # TODO 生成报错日志
  end

  private

  def update_corpus_comments_count! article
    corpus = article.corpus
    if corpus
      corpus.update! comments_count_cache: corpus.cal_comments_count
    end
  end
end
