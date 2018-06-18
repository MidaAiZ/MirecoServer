class IndexController < ApplicationController
  layout 'index'

  def check_login
    @user = Index::User.fetch_login session[:user_id], request
    @code = :NotLoggedIn unless @user # 用户未登录
    check_access # 检查用户帐号是否正常
  end

  def require_login
    check_login
    render json: { code: @code } and return unless @user
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
