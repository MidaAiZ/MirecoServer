class Index::Workspace::EditCommentsController < IndexController
  before_action :require_login
  before_action :set_resource
  before_action :check_permission, only: [:add_reply, :remove_reply, :destroy]
  before_action :set_edit_comment, only: [:show, :add_reply, :remove_reply, :destroy]
  before_action :set_replies, only: [:show, :add_reply, :remove_reply]


  def index
    @edit_comments = @resource ? @resource.edit_comments.includes(replies: :user) : Index::Workspace::EditComment.none
  end

  def show
  end

  def create
    @edit_comment = Index::Workspace::EditComment.new(edit_comment_params)
    # 权限
    if @user.can_edit?(:comment, @resource)
        @edit_comment.user = @user
        @edit_comment.resource = @resource
        @code = @edit_comment.save ? :Success : :Fail
    else
        @code = :NoPermission
    end

    respond_to do |format|
      if  @edit_comment.id.nil?
        format.json { render json: { code: @code }, status: :unprocessable_entity }
      else
        format.json { render :show, status: :created }
      end
    end
  end

  def add_reply
    @reply = Index::Workspace::EditCommentReply.new content: params[:reply]

    # 权限
    if @user.can_edit?(:comment, @resource)
        @reply.user = @user
        @reply.edit_comment = @edit_comment

        @code = @reply.save ? :Success : :Fail
    else
        @code ||= :NoPermission
    end
    respond_to do |format|
      format.json { render :show, status: @reply.id.nil? ? :unprocessable_entity : :created  }
    end
  end

  def remove_reply
    @reply = @edit_comment.replies.find(params[:reply_id])
    if @reply
      # 允许删除回复的条件
      if @reply.user == @user || # 1: 回复者
         @edit_comment.user == @user || # 2: 评论者
         @user.can_edit?(:delete_comment, @resource) # 3. 具有删除评论权限的用户

        @code = @reply.destroy ? :Success : :Fail
      else
        @code = :NoPermission
      end
    end
    @code ||= :Fail

    respond_to do |format|
      format.json { render :show }
    end
  end

  def destroy
    # 允许删除评论的条件
    @code = if @edit_comment.user == @user || # 1: 评论者
               @user.can_edit?(:delete_comment, @resource) # 2: 具有删除评论权限的用户

              @edit_comment.destroy ? :Success : :Fail
            else
              :NoPermission
            end
    render json: { code: @code }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_edit_comment
    edit_comment_cache params[:id] if @resource
    render(json: { code: :ResourceNotExist }) && return unless @edit_comment
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
    render(json: { code: :ResourceNotExist }) && return unless @resource
  end

  def set_replies
    @replies = @edit_comment.replies.includes(:user)
  end

  def check_permission
    render(json: { code: :NoPermission }) unless @user.can_edit?(:comment, @resource)
  end

  def reply_key
    "#{@user.id}-#{[*('s'..'z'), *(0..9)].sample(4).join}-#{Time.now.to_i}"
  end
end
