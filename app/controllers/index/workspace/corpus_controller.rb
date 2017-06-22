class Index::Workspace::CorpusController < IndexController
  before_action :check_login
  before_action :set_corpus, except: [:index, :new, :create]

  # GET /index/corpuss
  # GET /index/corpuss.json
  def index
    count = params[:count] || 15
    page = params[:page] || 1

    @nonpaged_corpuses = @user ? @user.corpuses : Index::Workspace::Corpus.none
    @corpuses = @nonpaged_corpuses.page(page).per(count)
  end

  # GET /index/corpuss/1
  # GET /index/corpuss/1.json
  def show
  end

  # POST /index/corpuss
  # POST /index/corpuss.json
  def create
    @corpus = Index::Workspace::Corpus.new(corpus_params)

    # 在用户登录的情况下才可以创建
    if @user && @corpus.valid?
      # 判断新建文章的路径
      folder_id = params[:corpus][:folder_id] if params[:corpus]
      if folder_id && folder_id != 0 # 将文章新建在某个文集或者文件夹内
        dir = Index::Workspace::Folder.find_by_id(folder_id)
        @code = if dir && @user.can_edit?(:create, dir) # 验证权限
                  @corpus.create(dir, @user) ? 'Success' : 'Fail'
                else
                  'NoPermission' # 没有权限
                end
      else
        @code = @corpus.create(0, @user) ? 'Success' : 'Fail'
      end
    end
    @code ||= 'Fail'
    render :show, status: @corpus.id.nil? ? :unprocessable_entity : :created
  end

  # PATCH/PUT /index/corpuss/1
  # PATCH/PUT /index/corpuss/1.json
  def update
    prms = corpus_update_params # 获取更新数据
    if prms.any? && @user
      if @user.can_edit? :update, @corpus
        if @corpus.is_shown || @corpus.is_deleted  # 已发表或者删除的文集禁止编辑
          @code = "StatusError"
        else
          @code = @corpus.update(prms) ? 'Success' : 'Fail'
        end
      else
        @code ||= 'NoPermission'
      end
    end

    do_update_response
  end

  # put /corpus/:i/publish
  def publish
    publish = params[:is_shown]
    if @user && @corpus
      if [true, false].include? publish
        @code = if @user.can_edit? :publish, @corpus
                  @corpus.update(is_shown: publish) ? 'Success' : 'Fail'
                else
                  'NoPermission'
                end
      end
    end
    @code ||= 'Fail'
    render json: { code: @code }
  end

  # put /corpus/:i/move_dir
  def move_dir
    render(json: { code: @code }) && return if @code # 用户未登录或者找不到文件

    if @corpus
      # 分两种情况, 第一种把文件移动到根目录, 第二种把文件移动到另一个文件夹
      if params[:dir] == 0 # 将文件移动到根目录
        dir = 0
      else
        dir_id = params[:folder_id]
        dir = Index::Workspace::Folder.find_by_id(dir_id) if dir_id
      end
      # 检查用户对目标文件的权限
      if dir == 0 || @user.can_edit?(:move_dir, dir)
        @code = @corpus.move_dir(dir, @user) ? 'Success' : 'Fail'
      end
    end

    @code ||= 'NoPermission'
    do_update_response
  end

  # DELETE /index/corpuss/1
  # DELETE /index/corpuss/1.json
  def destroy
    unless @code # 用户已登录, 文件已找到
      @code = if @user.can_edit? :delete, @corpus
                @corpus.delete_files ? 'Success' : 'Fail'
              else
                'NoPermission'
              end
    end
    render json: { code: @code }
  end

  def show_profile
    # 检索到该文集
    if @corpus
      @son_articles = @user.all_articles.where id: @corpus.info['articles'] || Index::Workspace::Corpus.none # 子文章
    #   @son_articles = @corpus.son_articles # 子文章
      @code = 'Success'
    end

    @code ||= 'Fail'
  end

  def add_editor
    role = params[:role]
    if @user && @corpus
      if @user.can_edit?(:add_role, @corpus) && Index::Role::Edit.allow_roles.include?(role)
        editor = Index::User.find_by_id params[:user_id]
        @code = editor.add_edit_role(role, @corpus) ? 'Success' : 'Fail' if editor
      else
        @code ||= 'NoPermission'
      end
    end
    @code ||= 'Fail'
    render json: { code: @code }
  end

  def remove_editor
    if @user && @corpus
      if @user.can_edit?(:remove_role, @corpus)
        editor = Index::User.find_by_id params[:user_id]
        @code = editor.remove_edit_role(@corpus) ? 'Success' : 'Fail' if editor
      else
        @code ||= 'NoPermission'
      end
    end
    @code ||= 'Fail'
    render json: { code: @code }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_corpus
    @corpus = @user.all_corpuses.find_by_id(params[:id]) if @user
    @code ||= 'ResourceNotExist' unless @corpus
  end

  # 新建文集的时候允许传入的参数
  def corpus_params
    params.require(:corpus).permit(:name, :tag, :is_shown, :is_marked)
  end

  # 更新文集的时候允许传入的参数
  def corpus_update_params
    params.require(:corpus).permit(:name, :tag, :is_marked)
  end

  def do_update_response
    respond_to do |format|
      format.json { render :show }
    end
  end
end
