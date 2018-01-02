require_relative "file_controller_module"

class Index::Workspace::CorpusController < IndexController
  include FileController

  before_action :require_login
  before_action :set_corpus, except: [:index, :new, :create]
  before_action :set_file, only: [:update, :mark, :unmark, :rename, :add_editor, :remove_editor, :move_dir, :publish, :destroy]

  # GET /index/corpuss
  # GET /index/corpuss.json
  def index
    count = params[:count] || 15
    page = params[:page] || 1

    @res = Rails.cache.fetch("#{cache_key}/#{@user.id}/#{page}/#{count}", expires_in: 5.minutes) do
      @nonpaged_corpuses = @user.corpuses
      res = @nonpaged_corpuses.page(page).per(count)
      { record: res.records, counts: count_cache(cache_key, res) }
    end
    @corpuses = @res[:record]; @counts = @res[:counts]
  end

  # POST /index/corpuss
  # POST /index/corpuss.json
  def create
    @corpus = Index::Workspace::Corpus.new(corpus_params)

    # 判断新建文章的路径
    folder_id = params[:corpus][:folder_id] if params[:corpus]
    if folder_id && folder_id != 0 # 将文章新建在某个文集或者文件夹内
      dir = Index::Workspace::Folder.find_by_id(folder_id)
      @code = if dir && @user.can_edit?(:create, dir) # 验证权限
                @corpus.create(dir, @user) ? :Success : :Fail
              else
                :NoPermission # 没有权限
              end
    else
      @code = @corpus.create(0, @user) ? :Success : :Fail
    end
    @code ||= :Fail
    render :show, status: @corpus.id.nil? ? :unprocessable_entity : :created
  end

  def show_profile
    @son_articles = @user.all_articles.where id: @corpus.info['articles'] || Index::Workspace::Corpus.none # 子文章
    #   @son_articles = @corpus.son_articles # 子文章
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_corpus
    edit_corpus_cache(params[:id])
    render(json: { code: :ResourceNotExist }) && return unless @corpus
  end

  def set_file
    @file = @corpus
  end

  def set_dir dir_id
    Index::Workspace::Folder.find_by_id(dir_id)
  end

  # 新建文集的时候允许传入的参数
  def corpus_params
    params.require(:corpus).permit(:name, :tag, :cover)
  end

  # 更新文集的时候允许传入的参数
  def corpus_update_params
    params.require(:corpus).permit(:name, :tag, :cover)
  end

end
