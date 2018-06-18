class Index::SessionController < IndexController
  layout false

  def index
    # 判断视图是否显示验证码，连续登录失败两次后需输入验证码
    @show_code = true if get_record[:times] >= 2

    # redirect_to root_path if session[:user_id] && @user = Index::user.find(session[:user_id])
  end

  def login
    # 检查是否已经登录
    if session[:user_id]
      check_login
      #防止极端情况下user_id作废,例如用户被删除, 从健壮性考虑以下处理session[:user_id]
      session[:user_id] = nil unless @user
    else
      prms = login_params
      # 检查登录失败次数判断是否需要输入验证码
      @fail_times = get_record[:times]
      # 连续登录失败两次后要求输入密码,防止暴力破解
      if @fail_times >= 2 && !verify_rucaptcha?(params[:_rucaptcha]) #, keep_session: true)
        #当连续登录失败两次时返回验证码,如果第三次登录时验证码错误则返回'WrongMsgCode'
        @code = @fail_times == 2 ? @code : 'WrongImgCode' # 验证码错误 'WrongMsgCode'
        @url = root_url + 'rucaptcha' #验证码地址
      elsif prms.blank?
        @code = 'InvalidParams' #参数错误
      else
        # 判断登录方式
        case prms[:login_type]
        when 'phone' #手机号+密码登录
          @user = Index::User.find_by_phone(prms[:phone]).try(:authenticate, prms[:password]) if prms[:phone] && prms[:password]
        when 'email' #邮箱+密码登录
          @user = Index::User.find_by_email(prms[:email]).try(:authenticate, prms[:password]) if prms[:email] && prms[:password]
        when 'msg_code' #手机号+短信验证码登录
          if prms[:phone] && prms[:msg_code]
            # 获取短信验证码记录
            msg_cache_key = Valicode.msg_cache_key(prms[:phone], "login")
            @cache ||= Cache.new
            msg_record = @cache[msg_cache_key]
            if msg_record #获取到记录才进行验证
              if prms[:msg_code] == msg_record[:code]
                @user = Index::User.find_by_phone(prms[:phone])
                @cache[msg_cache_key] = nil if @user #登录后删除缓存
              else
                #同一个短信验证码最多允许验证失败5次
                tem_cache = msg_record[:times] > 4 ? nil : { code: msg_record[:code], times: msg_record[:times] + 1 }
                @cache[msg_cache_key, 10.minutes] = tem_cache
                @code = 'WrongMsgCode'
              end
            end
          end
        else #默认帐号密码登录
          @user = Index::User.find_by_number(prms[:number]).try(:authenticate, prms[:password]) if prms[:number] && prms[:password]
        end

        check_access # 当查找到用户时检查帐号是否被冻结
        @user.class.fetch_login(@user.id, request) if @user
      end
    end

    respond_to do |format|
      if @user
        @code = :Success # 登录成功
        session[:user_id] = @user.id
        clear_record
        format.json { render 'index/users/show' }
        format.html { redirect_to root_path }
      else
        record_fail
        @code ||= :Fail
        format.json { render json: { code: @code } }
        format.html { redirect_to login_path, notice: @code }
      end
    end
  end

  def logout
    session[:user_id] = nil
    @code = session[:user_id] ? :Fail : :Success
    respond_to do |format|
      format.json { render json: { code: @code } }
      format.html { redirect_to root_path }
    end
  end

  private

  def login_params
      params.require(:user).permit(:number, :password, :phone, :email, :msg_code, :login_type)
  end

  def record_fail
    record = get_record
    new_record = { times: record[:times] + 1, last_try: Time.now }
    @cache[login_cache_key, 10.minute] = new_record
    new_record
  end

  def get_record
    @cache ||= Cache.new
    record = @cache[login_cache_key]
    if record
      record
    else
      { times: 0, last_try: Time.now }
    end
  end

  def clear_record
    @cache ||= Cache.new('index-')
    @cache[login_cache_key] = nil
  end

  def login_cache_key
    'login_session' + request.remote_ip
  end
end
