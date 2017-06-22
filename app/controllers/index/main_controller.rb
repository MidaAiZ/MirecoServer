class Index::MainController < IndexController
  before_action :check_login

  def index
  end

  def articles
    tag = params[:tag]
    count = params[:count] || 15
    page = params[:page] || 1
    count = 100 if count.to_i > 100  # 限制返回的条数

    @nonpaged_articles = Index::Workspace::Article.shown.sort(tag)
    @articles = @nonpaged_articles.page(page).per(count)
  end

  def show_article
    @article = Index::Workspace::Article.shown.find_by_id(params[:id])
  end

  def corpus
    tag = params[:tag]
    count = params[:count] || 15
    page = params[:page] || 1

    count = 100 if count.to_i > 100  # 限制返回的条数
    @nonpaged_corpus = Index::Workspace::Corpus.shown.sort(tag)
    @corpus = @nonpaged_corpus.page(page).per(count)
  end

  def show_corpus
    @corpus = Index::Workspace::Corpus.shown.find_by_id(params[:id])
  end

end
