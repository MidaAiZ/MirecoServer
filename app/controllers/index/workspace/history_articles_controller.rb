class Index::Workspace::HistoryArticlesController < IndexController
  before_action :check_login
  before_action :set_history_article, only: [:show, :destroy]

  #历史文章不允许通过表单创建，只能使用post请求，传入源文章id即可
  #历史文章不允许更新，可以删除

  # GET /index/history_articles
  # GET /index/history_articles.json
  def index
    art_id = params[:article_id]

    #用户已登录且检索得到源文章时返回其历史文章
    @article = @user.all_articles.find_by_id(art_id) if @user
    @history_articles = @article ? @article.history : []
  end

  # GET /index/history_articles/1
  # GET /index/history_articles/1.json
  def show
  end

  # POST /index/history_articles
  # POST /index/history_articles.json
  def create

    @history_article = Index::Workspace::HistoryArticle.new()

    if @user  #仅当用户登录时可更新
      art_id = params[:article_id]
      @article = @user.all_articles_with_content.find_by_id(art_id)

      if @article && @user.can_edit?(:add_history, @article)
        #如果检索到该文章则将各值赋给历史文章
        @history_article.origin = @article
        @history_article.name = @article.name
        @history_article.tag = @article.tag
        @history_article.content = @article.content
        @code = 'Success'if @history_article.save
      else #检索不到目标文章
        @code = 'NoPermission'
        @history_article.errors.add(:base, "找不到文章或没有权限")
      end
    end

    render :show, status: @history_article.id.nil? ? :unprocessable_entity : :created
  end

  # DELETE /index/history_articles/1
  # DELETE /index/history_articles/1.json
  def destroy
    if @history_article
        if @user.can_edit? :add_history, @article
            @code = 'Success' if @history_article.destroy
        else
            @code = 'NoPermission'
        end
    end

    @code ||= 'Fail'

    respond_to do |format|
      if @code == 'Success'
        format.json { render json: { code: @code } }
      else
        @code ||= 'Fail'
        format.json { render json: { code: @code } }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_history_article
      #检索到历史文章的必要条件
      #1.在用户已登录
      #2.检索到该历史文章
      #3.该历史文章的源文章属于登录用户
      @article = @user.all_articles.find_by_id(params[:article_id]) if @user
      @history_article = @article.history.find_by_id(params[:id]) if @article
      @code ||= 'ResouceNotExist' unless @history_article
    end
end
