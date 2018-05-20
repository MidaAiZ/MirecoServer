class Index::Workspace::CenterController < IndexController
  before_action :require_login
  before_action :set_resource, only: [:get_editors, :withdraw, :ws_token]

  def index
    init
    @nonpaged_edit_roles = @user.edit_roles.includes(file_seed: :root_file)
    @edit_roles = @nonpaged_edit_roles.page(@page).per(@count)
  end

  def marked_files
    @mark_records = @user.mark_records.includes(file: :file_seed)
  end

  def published_articles
    init
    @nonpaged_articles = @user.all_articles.shown.includes(:file_seed)
    @articles = @nonpaged_articles.page(@page).per(@count)
  end

  def published_corpuses
    init
    @nonpaged_corpuses = @user.all_corpuses.shown.includes(:file_seed)
    @corpuses = @nonpaged_corpuses.page(@page).per(@count)
  end

  def get_editors
    if @user.find_edit_role @resource
      @edit_roles = @resource.editor_roles.includes(:editor)
    end
    @edit_roles ||= []
    render :editors
  end

  def withdraw # 退出协同写作
    @code = if @user.can_edit?(:all, @resource)
              @resource.delete_files ? :Success : :Fail
            else
              @user.remove_edit_role(@resource) ? :Success : :Fail
            end
    @code ||= :Fail
    render json: { code: @code }
  end

  def ws_token # 获取socket io连接token
    role = @user.find_edit_role(@resource)
    @code = if role
              $redis.select 4
              cache_key = "ws_token_#{@user.id.to_s}_#{ @resource.id.to_s}_#{role.name}"
              @token = $redis.GET cache_key
              if !@token
                @token = (@user.id.to_s + '_' + @resource.id.to_s + rand.to_s).hash
                $redis.SET cache_key, @token
                # 1小时过期时间
                $redis.EXPIRE cache_key, 1 * 60 * 60
              end
              @code = :Success
            end
    @code ||= :Fail
    render json: { code: @code, token: @token }
  end

  private

  def init
    @count = params[:count] || 15
    @page = params[:page] || 1
  end

  def set_resource
    resource_type = params[:resource_type]
    resource_id = params[:resource_id]
    @resource = case resource_type
                when 'articles'
                  Index::Workspace::Article.fetch resource_id
                when 'corpuses'
                  Index::Workspace::Corpus.fetch resource_id
                when 'folders'
                  Index::Workspace::Folder.fetch resource_id
                end
    render(json: { code: :ResourceNotExist }) && return unless @resource
  end
end
