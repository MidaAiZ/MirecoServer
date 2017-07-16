class ReadWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'read_times'

  def perform(id, prefix)
    $redis.select 3
    article = Index::Workspace::Article.find(id)
    times = (article.rd_times || 0) + $redis.SCARD(prefix)
    article.update! rd_times: times
    set_corpus_read_times article

    $redis.del prefix
  rescue => e
    $redis.del prefix
    puts e
    # TODO 生成报错日志
  end

  private

  def set_corpus_read_times article
    if article.dir_type == "Index::Workspace::Corpus"
      corpus = article.dir
      times = (article.read_times || 0) + $redis.SCARD(prefix)
      corpus.update! read_times: times
    end
  end
end
