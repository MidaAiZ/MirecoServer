class ArtCommentWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'comment_count'

  def perform(id, prefix)
    $redis.select 3
    article = Index::PublishedArticle.find(id)
    times = (article.comments_count_cache) + $redis.SCARD(prefix) 
    article.update! comments_count_cache: times
    update_corpus_read_times

    $redis.del prefix
  rescue => e
    $redis.del prefix
    puts e
    # TODO 生成报错日志
  end

  private

  def update_corpus_read_times article
    corpus = article.corpus
    if corpus
      corpus.update! comments_count_cache: corpus.cal_comments_count
    end
  end
end
