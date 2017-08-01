class Index::MainController < IndexController
  before_action :check_login
  before_action :init, only: [:articles, :corpus]

  def index; end

  def articles
    @res = Rails.cache.fetch("#{cache_key}/#{@page}/#{@count}", expires_in: 3.minutes) do
      @nonpaged_articles = Index::Workspace::Article.shown # .sort(@tag)
      res = @nonpaged_articles.page(@page).per(@count)
      { record: res.records, counts: count_cache(cache_key, res) }
    end
    @articles = @res[:record]; @counts = @res[:counts]
  end

  def show_article
    shown_article_cache params[:id]
    @article.add_read_times mark if @article
    # @comments = @article.comments.limit(10).includes(:user) if @article
  end

  def corpus
    @res = Rails.cache.fetch("#{cache_key}/#{@page}/#{@count}", expires_in: 3.minutes) do
      @nonpaged_corpus = Index::Workspace::Corpus.shown # .sort(@tag)
      res = @nonpaged_corpus.page(@page).per(@count)
      { record: res.records, counts: count_cache(cache_key, res) }
    end
    @corpuses = @res[:record]; @counts = @res[:counts]
  end

  def show_corpus
    shown_corpus_cache params[:id]
  end

  private

  def init
    @tag = params[:tag]
    @count = params[:count] || 15
    @page = params[:page] || 1

    @count = 100 if @count.to_i > 100 # 限制返回的条数
  end

  def mark
    session[:user_id] || request.remote_ip
  end
end
