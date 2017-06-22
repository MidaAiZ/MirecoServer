class Index::Workspace::EditCommentsController < IndexController
  before_action :check_login
  before_action :set_resource
  before_action :set_edit_comment, only: [:show, :add_reply, :remove_reply, :destroy]

  def index
    @edit_comments = @resource ? @resource.edit_comments : Index::Workspace::EditComment.none
  end

  def show
  end

  def create
    @edit_comment = Index::Workspace::EditComment.new(edit_comment_params)

    unless @code
      @edit_comment.user = @user
      @edit_comment.resource = @resource
      @code = 'Success'if @edit_comment.save
    end

    @code ||= 'Fail'
    respond_to do |format|
      format.json { render :show, status: @edit_comment.id.nil? ? :unprocessable_entity : :created }
    end
  end

  def add_reply
    unless @code
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
    end
    @code ||= 'Fail'
    respond_to do |format|
      format.json { render :show }
    end
  end

  def remove_reply
    unless @code
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
    end
    @code ||= 'Fail'
    respond_to do |format|
      format.json { render :show }
    end
  end

  def destroy
    unless @code
      # 允许删除评论的条件
      if @edit_comment.user == @user || # 1: 评论者
        @user.can_edit?(:delete_comment, @resource) # 2: 具有删除评论权限的用户

        @code = @edit_comment.destroy ? 'Success' : 'Fail'
      else
        @code = 'NoPermission'
      end
    end
    render json: { code: @code }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_edit_comment
    @edit_comment = @resource.edit_comments.find_by_id params[:id] if @resource
    @code ||= 'ResourceNotExist' unless @edit_comment
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def edit_comment_params
    params.require(:edit_comment).permit(:hash_key, :content)
  end

  def set_resource
    if @user
      resource_type = params[:resource_type]
      resource_id = params[:resource_id]
      @resource = case resource_type
                  when 'articles'
                    Index::Workspace::Article.shown.find_by_id resource_id
                  end
      @code ||= 'ResourceNotExist' unless @resource
      @code ||= 'NoPermission' && @resource = nil if @resource && !@user.can_edit?(:comment, @resource)
    end
  end
end
