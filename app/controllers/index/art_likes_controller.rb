class Index::ArtLikesController < IndexController
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
    rsc_type = params[:resource_type]
    rsc_id = params[:resource_id]
    @resource = case rsc_type
                when 'articles'
                  Index::PublishedArticle.fetch rsc_id
                when 'art_comments'
                  Index::ArtComment.fetch rsc_id
                when 'art_replies'
                  Index::ArtCmtReply.fetch rsc_id
                end
    render(json: { code: :ResourceNotExist }) && return unless @resource
  end
end
