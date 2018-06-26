class Index::LikesController < IndexController
  before_action :require_login
  before_action :set_resource

  def create
    if @resource
      @code = @resource.add_like(@user) ? :Success : :Fail
    end
    render json: { code: @code }
  end

  def destroy
    if @resource
      @code =  @resource.delete_like(@user) ? :Success : :Fail
    end
    render json: { code: @code  }
  end

  private

  def set_resource
    resource_type = params[:resource_type]
    resource_id = params[:resource_id]
    @resource = case resource_type
                when 'articles'
                  Index::PublishedArticle.fetch resource_id
                when 'comments'
                  Index::Comment.fetch resource_id
                when 'replies'
                  Index::CommentReply.fetch resource_id
                end
    @code ||= :ResourceNotExist unless @resource
  end
end
