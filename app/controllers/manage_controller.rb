class ManageController < ApplicationController
  layout 'manage'
  before_action :require_login

  def check_login
    @admin = Manage::Admin.fetch_login session[:admin_id], request
    @code = :NotLoggedIn unless @admin # 用户未登录
  end

  def require_login
    check_login
    render json: { code: @code } and return unless @admin
  end

  # 权限检查
  def can? action, resource=''
    @admin.has_permission? action, resource
  end

  def require_permision action, resource=''
    render json: { code: :NoPermission } and return unless can?(action, resource)
  end

  def cache_key
    "#{params[:controller]}_#{params[:action]}"
  end

  def self.cache_key
    "#{params[:controller]}_#{params[:action]}"
  end
end
