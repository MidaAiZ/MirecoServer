class Index::Workspace::CenterController < IndexController
  before_action :require_login
  before_action :set_resource, only: [:get_editors, :withdraw]

  def index
    init
    @nonpaged_edit_roles = @user.edit_roles.includes(file_seed: :root_file)
    @edit_roles = @nonpaged_edit_roles.page(@page).per(@count)
  end

  def marked_files
    @mark_records = @user.mark_records.includes(:file, :file_seed)
  end

  def published_articles
    init
    @res = Rails.cache.fetch("#{cache_key}/#{@user.id}/#{@page}/#{@count}", expires_in: 3.minutes) do
      @nonpaged_articles = @user.all_articles.shown
      res = @nonpaged_articles.page(@page).per(@count)
      { record: res.records, counts: count_cache(cache_key, res) }
    end
    @articles = @res[:record]; @counts = @res[:counts]
  end

  def published_corpuses
    init
    @res = Rails.cache.fetch("#{cache_key}/#{@user.id}/#{@page}/#{@count}", expires_in: 3.minutes) do
      @nonpaged_corpuses = @user.all_corpuses.shown
      res = @nonpaged_corpuses.page(@page).per(@count)
      { record: res.records, counts: count_cache(cache_key, res) }
    end
    @corpuses = @res[:record]; @counts = @res[:counts]
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
              @resource.delete_files(@user) ? :Success : :Fail
            else
              @user.remove_edit_role(@resource) ? :Success : :Fail
            end
    @code ||= :Fail
    render json: { code: @code }
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
                  edit_article_cache resource_id
                when 'corpuses'
                  edit_corpus_cache resource_id
                when 'folders'
                  edit_folder_cache resource_id
                end
    render(json: { code: :ResourceNotExist }) && return unless @resource
  end
end
