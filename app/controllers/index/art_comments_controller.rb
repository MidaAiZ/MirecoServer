class Index::ArtCommentsController < IndexController
  include Index::ArtCommentsHelper
  before_action :check_login, except: [:create, :destroy]
  before_action :require_login, only: [:create, :destroy]
  before_action :set_article
  before_action :set_comment, only: [:show, :destroy]

  # GET /:articles/:art_id/comments
  def index
    page = params[:page] || 1
    count = params[:count] || 15
    count = 100 if count.to_i > 100  # 限制返回的评论条数
    @nonpaged_comments = @article ? @article.comments : Index::ArtComment.none
    @comments = @nonpaged_comments.page(page).per(count).includes(:user)
    attach_like_info @comments, @user
  end

  # GET /index/comments/1
  # GET /index/comments/1.json
  def show
    # @replies = @comment ? @comment.replies.limit(15) : Index::Comment.none
  end

  # POST /:articles/:art_id/comments
  def create
    @comment = @article.comment(@user, comment_params[:content])
    @code ||= @comment.id ? :Success : :Fail
    respond_to do |format|
      format.json { render :show, status: @comment.id ? :created : :unprocessable_entity }
    end
  end

  # DELETE /index/comments/1
  # DELETE /index/comments/1.json
  def destroy
    unless @code
      if @comment.can_be_deleted_by?(@user) # 判断用户是否有权限删除评论
        @code = @article.delete_comment(@comment) ? :Success : :Fail
      else
        @code = :NoPermission
      end
    end
    render json: { code: @code }
  end

  private

  def set_article
    @article = Index::PublishedArticle.fetch params[:art_id]
    @article = nil if @article && !@article.released?
    render(json: { code: :ResourceNotExist }) && return unless @article
  end

  def set_comment
    @comment = @article.comments.find_by_id(params[:id]) if @article
    render(json: { code: :ResourceNotExist }) && return unless @comment
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def comment_params
    params.require(:comment).permit(:content)
  end
end
