require_relative "file_controller_module"
class Index::Workspace::ArticlesController < IndexController
  include FileController

  before_action :require_login
  before_action :set_article, except: [:index, :new, :create]
  before_action :set_file, except: [:index, :create]

  # GET /index/articles
  # GET /index/articles.json
  def index
    count = params[:count] || 15
    page = params[:page] || 1
    @nonpaged_articles = @user.articles
    @articles = @nonpaged_articles.page(page).per(count)
  end

  # POST /index/articles
  # POST /index/articles.json
  def create
    @article = Index::Workspace::Article.new(article_params)

    # 判断新建文章的路径
    folder_id = params[:article][:folder_id]
    corpus_id = params[:article][:corpus_id]
    if (folder_id || corpus_id) && (folder_id != 0 && corpus_id != 0) # 将文章新建在某个文集或者文件夹内
      dir = folder_id.blank? ? Index::Workspace::Corpus.find_by_id(corpus_id) : Index::Workspace::Folder.find_by_id(folder_id)
      @code = if dir && @user.can_edit?(:create, dir) # 验证权限
                @article.create(dir, @user, {text: params[:article][:content]}) ? :Success : :Fail
              else
                :NoPermission # 没有权限
              end
    else
      @code = @article.create(0, @user, {text: params[:article][:content]}) ? :Success : :Fail
    end

    @code ||= :Fail
    render :show, status: @article.id.nil? ? :unprocessable_entity : :created
  end

  def update_content
    if @user.can_edit?(:edit, @article)
        if params[:content]
          @code = @article.update_content(params[:content]) ? :Success : :Fail
        end
    else
        @code = :NoPermission
    end
    @code ||= :Fail
    do_update_response
  end

  def release
    @release = @article.release
    @editor_roles = @release.editor_roles.includes(:editor) if @release
    @code ||= :NotReleaseYet unless @release
  end

  # 创建副本
  def copy
    if @user.can_edit? :copy, @article
      @article = @article.copy
    else
      :NoPermission
    end
    @code ||= @article.id ? :Success : :Fail

    render :show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_article
    @article = Index::Workspace::Article.fetch(params[:id])
    render(json: { code: :ResourceNotExist }) && return unless @article
  end

  def set_file
    @file = @article
  end

  def set_dir dir_id
      params[:corpus_id].blank? ? Index::Workspace::Folder.find_by_id(dir_id) : Index::Workspace::Corpus.find_by_id(dir_id)
  end

  # 新建文章的时候允许传入的参数
  def article_params
    params.require(:article).permit(:name, :tag, :cover)
  end

  # 更新文章的时候允许传入的参数
  def file_update_params
    params.require(:article).permit(:name, :tag, :cover)
  end

end
