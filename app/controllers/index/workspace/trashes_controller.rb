class Index::Workspace::TrashesController < IndexController
  before_action :require_login
  before_action :set_file, only: [:create]
  before_action :set_trash, only: [:show, :recover, :destroy]

  # GET /index/trashes
  # GET /index/trashes.json
  def index
    count = params[:count] || 15
    page = params[:page] || 1

    @nonpaged_trashes = @user.trashes
    @trashes = @nonpaged_trashes.page(page).per(count)
  end

  # GET /index/trashes/1
  # GET /index/trashes/1.json
  def show

  end

  # POST /index/trashes
  # POST /index/trashes.json
  def create
    @code = if @user.can_edit? :delete, @file
              @trash = Index::Workspace::Trash.delete_files(@file, @user)
              @trash && @trash.id ? :Success : :Fail
            else
              :NoPermission
            end

    render :show
  end

  def recover
    @code = @trash.recover_files ? :Success : :Fail
    render json: { code: @code }
  end

  # DELETE /index/trashes/1
  # DELETE /index/trashes/1.json
  def destroy # 仅文件拥有者才允许彻底删除文件
    @code = @trash.destroy_files ? :Success : :Fail
    render json: { code: @code }
  end

  private

  def set_trash
    @trash = @user.trashes.find_by_id params[:id]
    render(json: { code: :ResourceNotExist }) && return unless @trash
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def trash_params
    params.require(:trash).permit(:file_id, :file_type)
  end

  def set_file
    prms = trash_params
    file_type = prms[:file_type]
    file_id = prms[:file_id]
    if file_id && allow_files.include?(file_type)
      @file = case file_type
              when 'articles'
                @user.all_articles.find_by_id file_id
              when 'corpuses'
                @user.all_corpuses.find_by_id file_id
              when 'folders'
                @user.all_folders.find_by_id file_id
      end
    end
  end

  def allow_files
    %w(folders corpuses articles)
  end
end
