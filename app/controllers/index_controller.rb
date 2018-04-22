class IndexController < ApplicationController
  layout 'index'

  def check_login
    user_cache session[:user_id]
    @code = :NotLoggedIn unless @user # 用户未登录
    check_access # 检查用户帐号是否正常
  end

  def require_login
    check_login
    render json: { code: @code } and return unless @user
  end

  def user_cache(id)
    @user = init_cache :user, id
    unless @user
      @user = Index::User.find_by_id id
      @cache[@prefix] = @user if @user
    end
    @user
  end

  def comment_cache(id)
    @comment = init_cache :comment, id
    unless @comment
      @comment = @resource ? @resource.comments.find_by_id(id) : Index::Comment.find_by_id(id)
      @cache[@prefix] = @comment if @comment
    end
    @comment
  end

  def reply_cache(id)
    @reply = init_cache :reply, id
    unless @reply
      @reply = @comment ? @comment.replies.find_by_id(id) : Index::CommentReply.find_by_id(id)
      @cache[@prefix] = @reply if @reply
    end
    @reply
  end

  def shown_article_cache(id)
    @article = init_cache :article, id
    unless @article
      @article = Index::PublishedArticle.find_by_id id
      @cache[@prefix] = @article if @article
    end
    @article
  end

  def edit_article_cache(id)
    @article = init_cache :article, id, :edit_
    unless @article
      @article = @user.all_articles.find_by_id id
      @cache[@prefix] = @article if @article
    end
    @article
  end

  def shown_corpus_cache(id)
    @corpus = init_cache :corpus, id
    unless @corpus
      @corpus = Index::PublishedCorpus.find_by_id id
      @cache[@prefix] = @corpus if @corpus
    end
    @corpus
  end

  def edit_corpus_cache(id)
    @corpus = init_cache :corpus, id, :edit_
    unless @corpus
      @corpus = @user.all_corpuses.find_by_id id
      @cache[@prefix] = @corpus
    end
    @corpus
  end

  def edit_folder_cache(id)
    @folder = init_cache :folder, id, :edit_
    unless @folder
      @folder = @user.all_folders.find_by_id id
      @cache[@prefix] = @folder if @folder
    end
    @folder
  end

  def edit_comment_cache id
    @edit_comment = init_cache :edit_comment, id
    unless @edit_comment
      @edit_comment = @resource.edit_comments.find_by_id id
      @cache[@prefix] = @edit_comment if @edit_comment
    end
    @edit_comment
  end

  def init_cache(type, id, edit = "")
    @cache = Cache.new
    cache_prefix type, id, edit
    @cache[@prefix]
  end

  def cache_prefix type, id, edit
    @prefix = "#{edit}#{type}_#{id}"
  end

  def cache_key
    "#{params[:controller]}_#{params[:action]}"
  end

  def self.cache_key
    "#{params[:controller]}_#{params[:action]}"
  end

  def count_cache(key, res, expire = 10.minutes) # res是分页通过插件封装后的类对象
    Rails.cache.fetch("#{key}_counts", expires_in: expire) do
      res.total_count
    end
  end

  private

  def check_access
    if @user && @user.forbidden
      session[:user_id] = nil
      @user = nil
      @code = 'NoAccess' # 帐号被冻结
    end
    @user
  end
end
