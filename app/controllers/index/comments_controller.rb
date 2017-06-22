class Index::CommentsController < IndexController
  before_action :check_login, only: [:create, :destroy]
  before_action :set_resource
  before_action :set_comment, only: [:show, :destroy]

  # GET /:resource_type/:resource_id/comments
  def index
    page = params[:page] || 1
    count = params[:count] || 15
    count = 100 if count.to_i > 100  # 限制返回的评论条数
    @nonpaged_comments = @resource ? @resource.comments : Index::Comment.none
    @comments = @nonpaged_comments.page(page).per(count)
  end

  # GET /index/comments/1
  # GET /index/comments/1.json
  def show
    @replies = @comment ? @comment.replies.limit(15) : Index::Comment.none
  end

  # POST /:resource_type/:resource_id/comments
  def create
    @comment = Index::Comment.new(comment_params)

    unless @code
      @comment.resource = @resource
      @comment.user = @user
      @code = @comment.save ? 'Success' : 'Fail'
    end
    @code ||= 'Fail'
    respond_to do |format|
      format.json { render :show, status: @comment.id.nil? ? :unprocessable_entity : :created }
    end
  end

  # DELETE /index/comments/1
  # DELETE /index/comments/1.json
  def destroy
    unless @code
      if @user = @comment.user || @user.can_edit?(:comment, @resource)  # 判断用户是否有权限删除评论
        @code = @comment.destroy ? 'Success' : 'Fail'
      end
    end
    @code ||= 'Fail'
    render json: { code: @code }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_comment
    @comment = @resource.comments.find_by_id params[:id] if @resource
    @code ||= 'ResourceNotExist' unless @comment
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def comment_params
    params.require(:comment).permit(:content)
  end

  def set_resource
      resource_type = params[:resource_type]
      resource_id = params[:resource_id]
      case resource_type
      when 'articles'
        @resource = Index::Workspace::Article.shown.find_by_id resource_id
      when 'corpuses'
        @resource = Index::Workspace::Corpus.shown.find_by_id resource_id
      end
      @code = 'ResourceNotExist' unless @resource
  end
end
