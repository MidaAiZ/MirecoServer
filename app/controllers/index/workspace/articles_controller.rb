class Index::Workspace::ArticlesController < IndexController
  before_action :require_login
  before_action :set_article, except: [:index, :new, :create]

  # GET /index/articles
  # GET /index/articles.json
  def index
    count = params[:count] || 15
    page = params[:page] || 1
    @res = if @user
             Rails.cache.fetch("#{cache_key}/#{@user.id}/#{page}/#{count}", expires_in: 5.minutes) do
               @nonpaged_articles = @user.articles
               res = @nonpaged_articles.page(page).per(count)
               { record: res.records, counts: count_cache(cache_key, res) }
             end
           else
             { record: Index::Workspace::Article.none, counts: 0 }
           end
    @articles = @res[:record]; @counts = @res[:counts]
  end

  # GET /index/articles/1
  # GET /index/articles/1.json
  def show; end

  # POST /index/articles
  # POST /index/articles.json
  def create
    @article = Index::Workspace::Article.new(article_params)

    # 判断新建文章的路径
    folder_id = params[:article][:folder_id] if params[:article]
    corpus_id = params[:article][:corpus_id] if params[:article]
    if (folder_id || corpus_id) && (folder_id != 0 && corpus_id != 0) # 将文章新建在某个文集或者文件夹内
      dir = folder_id.blank? ? Index::Workspace::Corpus.find_by_id(corpus_id) : Index::Workspace::Folder.find_by_id(folder_id)
      @code = if dir && @user.can_edit?(:create, dir) # 验证权限
                @article.create(dir, @user) ? 'Success' : 'Fail'
              else
                'NoPermission' # 没有权限
              end
    else
      @code = @article.create(0, @user) ? 'Success' : 'Fail'
    end

    @code ||= 'Fail'
    render :show, status: @article.id.nil? ? :unprocessable_entity : :created
  end

  # 更新文章
  # PATCH/PUT /index/articles/1
  def update
    prms = article_update_params # 获取更新数据
    if @user.can_edit?(:update, @article)
      @code = if @article.is_shown || @article.is_deleted # 已发表或者删除的文章禁止编辑
                'StatusError'
              else
                @article.update(prms) ? 'Success' : 'Fail'
              end
    else
      @code ||= 'NoPermission'
    end

    do_update_response
  end

  # 发布文章
  # put /articles/:i/publish
  def publish
    publish = params[:is_shown]
    if [true, false].include? publish
      @code = if @user.can_edit? :publish, @article
                @article.update(is_shown: publish) ? 'Success' : 'Fail'
              else
                'NoPermission'
              end
    end
    @code ||= 'Fail'
    render json: { code: @code }
  end

  # put /articles/:id/move_dir
  def move_dir
    # 分两种情况, 第一种把文件移动到根目录, 第二种把文件移动到另一个文件夹
    if params[:dir] == 0 # 将文件移动到根目录
      dir = 0
    else
      dir_id = params[:folder_id] || params[:corpus_id]
      dir = params[:corpus_id].blank? ? Index::Workspace::Folder.find_by_id(dir_id) : Index::Workspace::Corpus.find_by_id(dir_id) if dir_id
    end
    # 检查用户对目标文件的权限
    if dir == 0 || @user.can_edit?(:move_dir, dir)
      @code = @article.move_dir(dir, @user) ? 'Success' : 'Fail'
    end

    @code ||= 'NoPermission'
    do_update_response
  end

  # DELETE /index/articles/1
  # DELETE /index/articles/1.json
  def destroy
    @code = if @user.can_edit? :delete, @article
              @article.delete_file ? 'Success' : 'Fail'
            else
              'NoPermission'
            end

    render json: { code: @code }
  end

  def add_editor
    role = params[:role]
    if @user.can_edit?(:add_role, @article) && Index::Role::Edit.allow_roles.include?(role)
      editor = Index::User.find_by_id params[:user_id]
      @code = editor.add_edit_role(role, @article) ? 'Success' : 'Fail' if editor
    else
      @code ||= 'NoPermission'
    end
    @code ||= 'Fail'
    render json: { code: @code }
  end

  def remove_editor
    if @user.can_edit?(:remove_role, @article)
      editor = Index::User.find_by_id params[:user_id]
      @code = editor.remove_edit_role(@article) ? 'Success' : 'Fail' if editor
    else
      @code ||= 'NoPermission'
    end
    @code ||= 'Fail'
    render json: { code: @code }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_article
    edit_article_cache(params[:id])
    render(json: { code: 'ResourceNotExist' }) && return unless @article
  end

  # 新建文章的时候允许传入的参数
  def article_params
    params.require(:article).permit(:name, :content, :tag, :is_shown, :is_marked)
  end

  # 更新文章的时候允许传入的参数
  def article_update_params
    params.require(:article).permit(:name, :content, :tag, :is_marked)
  end

  def do_update_response
    respond_to do |format|
      format.json { render :show }
    end
  end
end
