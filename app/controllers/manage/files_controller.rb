class Manage::FilesController < ManageController
  before_action :set_file, except: [:index]

  def index
    case params[:type]
    when "articles"
      @files = Index::PublishedArticle.page(params[:page]).per(params[:count])
      render :articles
    when "corpuses"
      @files = Index::PublishedCorpus.page(params[:page]).per(params[:count])
      render :corpuses
    else
      render json: { code: :WrongFileType }
    end
  end

  def show
    case params[:type]
    when "articles"
      render :article
    when "corpuses"
      render :corpuse
    else
      render json: { code: :WrongFileType }
    end
  end

  def update
    @code = @file.update(file_update_params) ? :Success : :Fail
    do_response
  end

  def forbid
    @code = @file.forbid ? :Success : :Fail
    do_response
  end

  def release
    @code = @file.release ? :Success : :Fail
    do_response
  end

  def review
    @code = @file.review ? :Success : :Fail
    do_response
  end

  def destroy
    @code = @file.destroy ? :Success : :Fail
    do_response
  end

  private

  def set_file
    case params[:type]
    when "articles"
      @file = Index::PublishedArticle.fetch params[:id]
    when "corpuses"
      @file = Index::PublishedCorpus.fetch params[:id]
    end
    render(json: { code: :ResourceNotExist }) && return unless @file
  end

  def file_update_params
    params.require(:file).permit(:name, :tag, :cover, :read_times_cache, :likes_count_cache, :comments_count_cache)
  end

  def do_response
    respond_to do |format|
      if @code == :Success
        if params[:type] == "articles"
          format.json { render :article, status: 200}
        else
          format.json { render :corpus, status: 200}
        end
      else
        format.json { render json: { code: @code, errors: @file.errors }, status: :unprocessable_entity}
      end
    end
  end
end
