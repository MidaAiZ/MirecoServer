class Index::Workspace::TrashesController < IndexController
  before_action :check_login
  before_action :set_trash, only: [:show, :recover]

  # GET /index/trashes
  # GET /index/trashes.json
  def index
    return @code unless @user
    file_seed_id = params[:file_seed_id]
    count = params[:count] || 15
    page = params[:page] || 1

    if file_seed_id
      @file_seed = @user.file_seeds.find_by_id(file_seed_id)
      @nonpaged_trashes = @file_seed.nil? ? Index::Workspace::Trash.none : @file_seed.trashes
    else
      @nonpaged_trashes = @user.trashes
    end
    @trashes = @nonpaged_trashes.page(page).per(count)

  end

  # GET /index/trashes/1
  # GET /index/trashes/1.json
  def show
  end

  # POST /index/trashes
  # POST /index/trashes.json
  def create
    file = set_file
    if file
      @code = if @user.can_edit? :delete, file
                @trash = Index::Workspace::Trash.delete_files(file)
                @trash ? 'Success' : 'Fail'
              else
                'NoPermission'
              end
    end

    @code ||= 'Fail'
    render :show
  end

  def recover
    if @trash
      if @user.can_edit? :delete, @trash.file_seed
        @code = @trash.recover_files ? 'Success' : 'Fail'
      else
        @code ||= 'NoPermission'
      end
    end
    @code ||= 'Fail'

    render json: { code: @code }
  end

  # DELETE /index/trashes/1
  # DELETE /index/trashes/1.json
  def destroy # 仅文件拥有者才允许彻底删除文件
    @trash = @user.trashes.find_by_id(params[:id]) if @user
    if @trash
      @code = @trash.destroy_files ? 'Success' : 'Fail'
    else
      @code = 'ResourceNotExist'
    end

    @code ||= 'Fail'
    render json: { code: @code }
  end

  private

  def set_trash
    if @user
      file_seed_id = params[:file_seed_id]

      if file_seed_id
        @file_seed = @user.file_seeds.find_by_id(file_seed_id)
        if @file_seed
          @trash = @file_seed.trashes.find_by_id params[:id]
        else
          @code ||= 'ResourceNotExist'
        end
      else
        @trash = @user.trashes.find_by_id params[:id]
      end
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def trash_params
    params.require(:trash).permit(:file_id, :file_type)
  end

  def set_file
    prms = trash_params
    file_type = prms[:file_type]
    file_id = prms[:file_id]
    if @user && file_id && allow_files.include?(file_type)
      case file_type
      when 'articles'
        file = @user.all_articles_with_content.find_by_id file_id
      when 'corpuses'
        file = @user.all_corpuses.find_by_id file_id
      when 'folders'
        file = @user.all_folders.find_by_id file_id
      end
    end
    file ||= nil
  end

  def allow_files
    %w(folders corpuses articles)
  end
end
