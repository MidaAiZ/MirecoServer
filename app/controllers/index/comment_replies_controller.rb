class Index::CommentRepliesController < IndexController
  before_action :require_login, only: [:create, :destroy]
  before_action :set_comment
  before_action :set_comment_reply, only: [:show, :destroy]

  def index
    page = params[:page] || 1
    count = params[:count] || 15
    count = 100 if count.to_i > 100 # 限制返回的评论条数
    @nonpaged_replies = @comment ? @comment.replies : Index::CommentReply.none
    @replies = @nonpaged_replies.page(page).per(count)
  end

  def show
  end

  def create
    @reply = Index::CommentReply.new(comment_reply_params)
    unless @code
      @code = @reply.create(@comment, @user) ? :Success : :Fail
    end
    respond_to do |format|
      format.json { render :show, status: @reply.id.nil? ? :unprocessable_entity : :created }
    end
  end

  def destroy
    unless @code
      if @reply.user == @user ||  # 删除条件1: 该回复的用户
          @comment.user == @user ||  # 删除条件2: 该回复的评论用户
          @user.can_edit?(:delete_comment, @comment.resource) # 删除条件3: 对文件具有编辑评论权限的协同作者
        @code = @reply.drop(@comment) ? :Success : :Fail
      else
        @code = :NoPermission
      end
    end
    render json: { code: @code }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_comment_reply
    reply_cache params[:id] if @comment
    @code ||= :ResourceNotExist unless @reply
  end

  def set_comment
    comment_cache params[:comment_id]
    @code ||= :ResourceNotExist unless @comment
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def comment_reply_params
    params.require(:reply).permit(:content)
  end
end
