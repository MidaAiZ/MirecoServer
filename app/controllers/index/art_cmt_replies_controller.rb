class Index::ArtCmtRepliesController < IndexController
  include Index::ArtCmtRepliesHelper

  before_action :check_login, except: [:create, :destroy]
  before_action :require_login, only: [:create, :destroy]
  before_action :set_comment
  before_action :set_reply, only: [:show, :destroy]

  # GET /:comments/:cmt_id/replies
  def index
    page = params[:page] || 1
    count = params[:count] || 15
    count = 100 if count.to_i > 100  # 限制返回的评论条数
    @nonpaged_replies = @comment ? @comment.replies : Index::ArtCmtReplies.none
    @replies = @nonpaged_replies.page(page).per(count).includes(:user)
    attach_like_info @replies, @user
  end

  # GET /index/comments/1
  # GET /index/comments/1.json
  def show
    # @replies = @reply ? @reply.replies.limit(15) : Index::Comment.none
  end

  # POST /:articles/:art_id/comments
  def create
    @reply = @comment.add_reply(@user, reply_params[:content])
    @code ||= @reply.id ? :Success : :Fail
    respond_to do |format|
      format.json { render :show, status: @reply.id ? :created : :unprocessable_entity }
    end
  end

  # DELETE /index/comments/1
  # DELETE /index/comments/1.json
  def destroy
    unless @code
      if @reply.can_be_deleted_by?(@user) # 判断用户是否有权限删除评论
        @code = @comment.delete_reply(@reply) ? :Success : :Fail
      else
        @code = :NoPermission
      end
    end
    render json: { code: @code }
  end

  private

  def set_comment
    @comment = Index::ArtComment.fetch params[:cmt_id]
    render(json: { code: :ResourceNotExist }) && return unless @comment
  end

  def set_reply
    @reply = @comment.replies.find_by_id(params[:id]) if @comment
    render(json: { code: :ResourceNotExist }) && return unless @reply
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def reply_params
    params.require(:comment).permit(:content)
  end
end
