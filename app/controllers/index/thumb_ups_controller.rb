class Index::ThumbUpsController < IndexController
  before_action :require_login
  before_action :set_resource

  def create
    if @resource
      @code = :Success if Index::ThumbUp.add(@resource, @user)
    end
    render json: { code: @code || :Fail }
  end

  def destroy
    if @resource
      @code = :Success if Index::ThumbUp.cancel(@resource, @user)
    end
    render json: { code: @code || :Fail }
  end

  private

  def set_resource
    resource_type = params[:resource_type]
    resource_id = params[:resource_id]
    @resource = case resource_type
                when 'articles'
                  shown_article_cache resource_id
                when 'corpuses'
                  shown_corpus_cache resource_id
                when 'comments'
                  comment_cache resource_id
                when 'replies'
                  reply_cache resource_id
                end
    @code ||= :ResourceNotExist unless @resource
  end
end
