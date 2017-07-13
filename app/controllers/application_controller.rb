class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  # before_filter :cors_preflight_check
  # after_filter :cors_set_headers
  #
  # def cors_preflight_check
  #   if request.method == 'OPTIONS'
  #     headers['Access-Controll-Allow-Origin'] = '*'
  #     headers['Access-Controll-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
  #     headers['Access-Controll-Allow-Headers'] = 'X-Requested-With, Content-Type, Accept'
  #     headers['Access-Controll-Max-Age'] = '1728000'
  #     render :text => '', :content - type => 'text/plain'
  #   end
  # end
  #
  # def cors_set_headers
  #   headers['Access-Controll-Allow-Origin'] = '*'
  #   headers['Access-Controll-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
  #   headers['Access-Controll-Max-Age'] = '1728000'
  # end
end
