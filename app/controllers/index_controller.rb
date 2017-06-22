class IndexController < ApplicationController
  layout 'index'

  def check_login
    @user = Index::User.find_by_id(session[:user_id]) if session[:user_id]
    @code = 'NotLoggedIn' unless @user #用户未登录
    check_access #检查用户帐号是否正常
  end

  private

  def check_access
    if @user && @user.forbidden
      session[:user_id] = nil
      @user = nil
      @code = 'NoAccess' #帐号被冻结
    end
    @user
  end

end
