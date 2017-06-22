class Index::VerifyController < IndexController
  def check_code
    if verify_rucaptcha? params[:_rucaptcha], keep_session: true
      render json: { code: 'Success' }
    else
      render json: { code: 'Fail' }
    end
  end

  def send_msg_code
    # 判断短信是发送给已登录用户还是发送给参数中的号码
    case params[:phone]
    when 'user_phone' # 发送给已登录用户
      @user = Index::User.find_by_id(session[:user_id])
      # 如果用户登录,则正常发送, 否则返回'NotLoggedIn'(用户未登录)
      @code = @user ? Valicode.set_msg_code(@user.phone, params[:handle]) : 'NotLoggedIn'
    else
      @code = Valicode.set_msg_code(params[:phone], params[:handle])
    end
    render json: { code: @code }
  end

  def check_msg_code
    @cache = Cache.new # 获取cache对象实例
    # 判断发送短信的手机号
    case params[:phone]
    when 'user_phone' #发送给已登录用户的手机号的验证码
      @user = Index::User.find_by_id(session[:user_id])
      # 如果用户登录,则正常发送, 否则返回'NotLoggedIn'(用户未登录)
      msg_cache_key = Valicode.msg_cache_key(@user.phone, params[:handle]) if @user
    else #发送给参数中手机号的验证码
      msg_cache_key = Valicode.msg_cache_key(params[:phone], params[:handle]) # 获取注册cache的key值
    end

    msg_record = @cache[msg_cache_key] # 从缓存中获取短信验证码记录
    msg_code = params[:msg_code] # 从参数中获取短信验证码

    # 验证短信验证码是否正确
    if msg_record
      if msg_code != msg_record[:code]
        # 每条验证码最多允许10次验证失败
        tem_cache = msg_record[:times] > 9 ? nil : { code: msg_record[:code], times: msg_record[:times] + 1 }
        @cache[msg_cache_key, 10.minutes] = tem_cache
        @code = 'Fail' # 短信验证码错误
      else
        @code = 'Success'# 验证成功
      end
    else
      @code = 'MsgCodeNotExist' # 短信验证码失效(不存在)
    end

    @code ||= 'Fail'
    render json: { code: @code }
  end

end
