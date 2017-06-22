class Index::ThumbUpsController < IndexController
  before_action :check_login
  before_action :set_resource

  def create
    if @resource
      @code = Index::ThumbUp.add(@resource, @user) ? 'Success' : 'Fail'
    end
    @code ||= 'Fail'
    render json: { code: @code }
  end

  def destroy
    if @resource
      @code = Index::ThumbUp.cancel(@resource, @user) ? 'Success' : 'Fail'
    end
    @code ||= 'Fail'
    render json: { code: @code }
  end

  private

  def set_resource
    return nil unless @user
    resource_type = params[:resource_type]
    resource_id = params[:resource_id]
    @resource = case resource_type
                when 'articles'
                  Index::Workspace::Article.shown.find_by_id resource_id
                when 'corpuses'
                  Index::Workspace::Corpus.shown.find_by_id resource_id
                when 'comments'
                  Index::Comment.find_by_id resource_id
                when 'replies'
                  Index::CommentReply.find_by_id resource_id
                end
    @code ||= 'ResourceNotExist' unless @resource
  end
end
