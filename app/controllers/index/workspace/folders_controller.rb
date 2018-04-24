require_relative "file_controller_module"

class Index::Workspace::FoldersController < IndexController
  include FileController

  before_action :require_login
  before_action :set_folder, except: [:index, :new, :create]
  before_action :set_file, except: [:index, :create, :profile]

  # GET /index/folders
  # GET /index/folders.json
  def index
    count = params[:count] || 15
    page = params[:page] || 1

    @nonpaged_folders = @user.folders
    @folders = @nonpaged_folders.page(page).per(count)
  end

  # POST /index/folders
  # POST /index/folders.json
  def create
    @folder = Index::Workspace::Folder.new(folder_params)

    # 判断新建文章的路径
    folder_id = params[:folder][:folder_id] if params[:folder]
    if folder_id && folder_id != 0 # 将文章新建在某个文集或者文件夹内
      dir = Index::Workspace::Folder.find_by_id(folder_id)
      @code = if dir && @user.can_edit?(:create, dir) # 验证权限
                @folder.create(dir, @user) ? :Success : :Fail
              else
                :NoPermission # 没有权限
              end
    else
      @code = @folder.create(0, @user) ? :Success : :Fail
    end
    @code ||= :Fail
    render :show, status: @folder.id.nil? ? :unprocessable_entity : :created
  end

  def profile
    # 检索到该文件夹
    @files = @folder.profiles @user
  end

  # 创建副本
  def copy
    if @user.can_edit? :copy, @folder
      @folder = @folder.copy
    else
      :NoPermission
    end
    @code ||= @folder.id ? :Success : :Fail

    render :show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_folder
    @folder = Index::Workspace::Folder.fetch params[:id]
    render(json: { code: :ResourceNotExist }) && return unless @folder
  end

  def set_file
    @file = @folder
  end

  def set_dir dir_id
    Index::Workspace::Folder.find_by_id(dir_id)
  end

  # 新建时允许传入的参数
  def folder_params
    params.require(:folder).permit(:name, :tag)
  end

  # 更新时允许传入的参数
  def file_update_params
    params.require(:folder).permit(:name, :tag)
  end
end
