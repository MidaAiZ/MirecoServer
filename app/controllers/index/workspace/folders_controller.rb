class Index::Workspace::FoldersController < IndexController
  before_action :require_login
  before_action :set_folder, except: [:index, :new, :create]

  # GET /index/folders
  # GET /index/folders.json
  def index
    count = params[:count] || 15
    page = params[:page] || 1

    @res = Rails.cache.fetch("#{cache_key}/#{@user.id}/#{page}/#{count}", expires_in: 5.minutes) do
      @nonpaged_folders = @user.folders
      res = @nonpaged_folders.page(page).per(count)
      { record: res.records, counts: count_cache(cache_key, res) }
    end
    @folders = @res[:record]; @counts = @res[:counts]
  end

  # GET /index/folders/1
  # GET /index/folders/1.json
  def show; end

  # POST /index/folders
  # POST /index/folders.json
  def create
    @folder = Index::Workspace::Folder.new(folder_params)

    # 判断新建文章的路径
    folder_id = params[:folder][:folder_id] if params[:folder]
    if folder_id && folder_id != 0 # 将文章新建在某个文集或者文件夹内
      dir = Index::Workspace::Folder.find_by_id(folder_id)
      @code = if dir && @user.can_edit?(:create, dir) # 验证权限
                @folder.create(dir, @user) ? 'Success' : 'Fail'
              else
                'NoPermission' # 没有权限
              end
    else
      @code = @folder.create(0, @user) ? 'Success' : 'Fail'
    end
    @code ||= 'Fail'
    render :show, status: @folder.id.nil? ? :unprocessable_entity : :created
  end

  # PATCH/PUT /index/folders/1
  # PATCH/PUT /index/folders/1.json
  def update
    prms = folder_update_params # 获取更新数据
    if @user.can_edit?(:update, @folder)
      @code = if @folder.is_deleted # 已删除的文集禁止编辑
                'StatusError'
              else
                @folder.update(prms) ? 'Success' : 'Fail'
              end
    else
      @code ||= 'NoPermission'
    end

    do_update_response
  end

  def move_dir
    # 分两种情况, 第一种把文件移动到根目录, 第二种把文件移动到另一个文件夹
    if params[:dir] == 0 # 将文件移动到根目录
      dir = 0
    else
      dir_id = params[:folder_id]
      dir = Index::Workspace::Folder.find_by_id(dir_id) if dir_id
    end
    # 检查用户对目标文件的权限
    if dir == 0 || @user.can_edit?(:move_dir, dir)
      @code = @folder.move_dir(dir, @user) ? 'Success' : 'Fail'
    end

    @code ||= 'NoPermission'
    do_update_response
  end

  # DELETE /index/folders/1
  # DELETE /index/folders/1.json
  def destroy
    @code = if @user.can_edit? :delete, @folder
              @folder.delete_files ? 'Success' : 'Fail'
            else
              'NoPermission'
            end
    render json: { code: @code }
  end

  def add_editor
    role = params[:role]
    if @user.can_edit?(:add_role, @folder) && Index::Role::Edit.allow_roles.include?(role)
      editor = Index::User.find_by_id params[:user_id]
      @code = editor.add_edit_role(role, @folder) ? 'Success' : 'Fail' if editor
    else
      @code ||= 'NoPermission'
    end
    @code ||= 'Fail'
    render json: { code: @code }
  end

  def remove_editor
    if @user.can_edit?(:remove_role, @folder)
      editor = Index::User.find_by_id params[:user_id]
      @code = editor.remove_edit_role(@folder) ? 'Success' : 'Fail' if editor
    else
      @code ||= 'NoPermission'
    end
    @code ||= 'Fail'
    render json: { code: @code }
  end

  def show_profile
    # 检索到该文件夹
    @son_folders = @user.all_folders.where id: @folder.info['folders'] || Index::Workspace::Folder.none # 子文件夹
    @son_articles = @user.all_articles.where id: @folder.info['articles'] || Index::Workspace::Article.none # 子文章
    @son_corpuses = @user.all_corpuses.where id: @folder.info['corpuses'] || Index::Workspace::Corpus.none # 子文集
    # @father_folder = @folder.father_folder #父文件夹
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_folder
    edit_folder_cache(params[:id])
    render(json: { code: 'ResourceNotExist' }) && return unless @folder
  end

  # 新建时允许传入的参数
  def folder_params
    params.require(:folder).permit(:name, :tag, :is_marked)
  end

  # 更新时允许传入的参数
  def folder_update_params
    params.require(:folder).permit(:name, :tag, :is_marked)
  end

  def do_update_response
    respond_to do |format|
      format.json { render :show }
    end
  end
end
