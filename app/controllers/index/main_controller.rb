class Index::MainController < IndexController
  before_action :check_login
  before_action :init, only: [:articles, :corpus]

  def index; end

  def articles
    @res = Rails.cache.fetch("#{cache_key}/#{@page}/#{@count}", expires_in: 10.minutes) do
      @nonpaged_articles = Index::PublishedArticle.recommend # .sort(@tag)
      res = @nonpaged_articles.page(@page).per(@count).includes(:author)
      { record: res.records, counts: count_cache(cache_key, res) }
    end
    @articles = @res[:record]; @counts = @res[:counts]
  end

  def show_article
    shown_article_cache params[:id]
    if @article
      @editor_roles = @article.editor_roles.includes(:editor)
      @article.read request.remote_ip, @user
    else
      @code ||= :ResourceNotExist
    end
  end

  def corpuses
    @res = Rails.cache.fetch("#{cache_key}/#{@page}/#{@count}", expires_in: 10.minutes) do
      @nonpaged_corpus = Index::PublishedCorpus.recommend # .sort(@tag)
      res = @nonpaged_corpus.page(@page).per(@count).includes(:author)
      { record: res.records, counts: count_cache(cache_key, res) }
    end
    @corpuses = @res[:record]; @counts = @res[:counts]
  end

  def show_corpus
    shown_corpus_cache params[:id]
    if @corpus
      @editor_roles = @corpus.editor_roles.includes(:editor)
    else
      @code = :ResourceNotExist
    end
  end

  def hot_articles
    @res = Rails.cache.fetch("#{cache_key}/#{@page}/#{@count}", expires_in: 10.minutes) do
      @nonpaged_articles = Index::PublishedArticle.hot # .sort(@tag)
      res = @nonpaged_articles.page(@page).per(@count).includes(:author)
      { record: res.records, counts: count_cache(cache_key, res) }
    end
    @articles = @res[:record]; @counts = @res[:counts]
    render :articles
  end

  def hot_corpuses
    @res = Rails.cache.fetch("#{cache_key}/#{@page}/#{@count}", expires_in: 10.minutes) do
      @nonpaged_articles = Index::PublishedCorpus.hot # .sort(@tag)
      res = @nonpaged_articles.page(@page).per(@count).includes(:author)
      { record: res.records, counts: count_cache(cache_key, res) }
    end
    @articles = @res[:record]; @counts = @res[:counts]
    render :corpuses
  end

  private

  def init
    @tag = params[:tag]
    @count = params[:count] || 15
    @page = params[:page] || 1

    @count = 100 if @count.to_i > 100 # 限制返回的条数
  end
end
