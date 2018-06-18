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

  def releases
    @files = @user.published_files
  end

  def co_releases
    @files = @user.co_published_files
    render :published_files
  end

  def released_articles
    init
    @nonpaged_articles = @user.published_articles.includes(:origin)
    @articles = @nonpaged_articles.page(@page).per(@count)
  end

  def released_corpuses
    init
    @nonpaged_corpuses = @user.published_corpuses.includes(:origin)
    @corpuses = @nonpaged_corpuses.page(@page).per(@count)
  end

  def delete_release # 删除已发表文章
    case params[:type]
    when "articles"
      @file = Index::PublishedArticle.fetch params[:id]
    when "corpuses"
      @file = Index::PublishedCorpus.fetch params[:id]
    end

    @code = if @file
              if @user.can_edit?(:all, @file.origin)
                @file.origin.delete_files ? :Success : :Fail
              elsif @file.origin
                @user.remove_edit_role(@file.origin) ? :Success : :NoPermission
              elsif @file.user_id == @user.id # 源文件不存在的情况
                @file.destroy ? :Success : :Fail
              end
            end

    @code ||= :ResourceNotExist
    render json: { code: @code }
  end

  def get_editors
    if @user.find_edit_role @resource
      @edit_roles = @resource.editor_roles.includes(:editor)
    end
    @edit_roles ||= []
    render :editors
  end

  def quit # 退出协同写作
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
    @code ||= :NoPermission
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
