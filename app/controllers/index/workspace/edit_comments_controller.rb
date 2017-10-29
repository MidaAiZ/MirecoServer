class Index::Workspace::EditCommentsController < IndexController
  before_action :require_login
  before_action :set_resource
  before_action :check_permission, only: [:add_reply, :remove_reply, :destroy]
  before_action :set_edit_comment, only: [:show, :add_reply, :remove_reply, :destroy]

  def index
    @edit_comments = @resource ? @resource.edit_comments : Index::Workspace::EditComment.none
  end

  def show; end

  def create
    @edit_comment = Index::Workspace::EditComment.new(edit_comment_params)

    @edit_comment.user = @user
    @edit_comment.resource = @resource
    @code = @edit_comment.save ? 'Success' : 'Fail'

    respond_to do |format|
      format.json { render :show, status: @edit_comment.id.nil? ? :unprocessable_entity : :created }
    end
  end

  def add_reply
    if params[:reply] && params[:reply].size < 255
      reply = {
        user_id: @user.id,
        content: params[:reply]
      }
      @edit_comment.replies[Time.now.strftime('%Y-%m-%d %H:%M:%S')] = reply
      @code = @edit_comment.save ? 'Success' : 'Fail'
    else
      @edit_comment.errors[:base] = 'size of reply should be 1-255'
    end
    @code ||= 'Fail'
    respond_to do |format|
      format.json { render :show }
    end
  end

  def remove_reply
    key = params[:hash_key]
    if @edit_comment.replies.key?(key)
      # 允许删除回复的条件
      if @edit_comment.replies[key]['user_id'] == @user.id || # 1: 回复者
         @edit_comment.user == @user || # 2: 评论者
         @user.can_edit?(:delete_comment, @resource) # 3. 具有删除评论权限的用户

        @edit_comment.replies.delete key
        @code = @edit_comment.save ? 'Success' : 'Fail'
      else
        @code = 'NoPermission'
      end
    end
    @code ||= 'Fail'
    respond_to do |format|
      format.json { render :show }
    end
  end

  def destroy
    # 允许删除评论的条件
    @code = if @edit_comment.user == @user || # 1: 评论者
               @user.can_edit?(:delete_comment, @resource) # 2: 具有删除评论权限的用户

              @edit_comment.destroy ? 'Success' : 'Fail'
            else
              'NoPermission'
            end
    render json: { code: @code }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_edit_comment
    edit_comment_cache params[:id] if @resource
    render(json: { code: 'ResourceNotExist' }) && return unless @edit_comment
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def edit_comment_params
    params.require(:edit_comment).permit(:hash_key, :content)
  end

  def set_resource # 之后可能会添加其它的编辑评论对象，此方法方便扩展
    resource_type = params[:resource_type]
    resource_id = params[:resource_id]
    @resource = case resource_type
                when 'articles'
                  edit_article_cache resource_id
                end
    render(json: { code: 'ResourceNotExist' }) && return unless @resource
  end

  def check_permission
    render(json: { code: 'NoPermission' }) unless @user.can_edit?(:comment, @resource)
  end
end
