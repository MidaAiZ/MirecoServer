class Index::UsersController < IndexController
  before_action :require_login, except: [:new, :create, :check_uniq, :search]

  # GET /index/users/profile
  def show
    @code ||= :Success
  end

  # GET /index/users/new
  def new
    @user = Index::User.new
  end

  # GET /index/users/1/edit
  def edit; end

  # POST /index/users
  # POST /index/users.json
  def create
    prms = index_user_params # 获取注册参数
    @user = Index::User.new(prms) # 新建用户

    @cache = Cache.new # 获取cache对象实例
    msg_cache_key = Valicode.msg_cache_key(prms[:phone], 'register') # 获取注册cache的key值
    msg_record = @cache[msg_cache_key] # 从缓存中获取短信验证码记录

    msg_code = params[:msg_code] # 从注册参数中获取短信验证码

    # 验证注册传入的短信验证码是否正确
    unless msg_record && (msg_code == msg_record[:code])
        # 每条验证码最多允许5次验证失败
        tem_cache = msg_record[:times] > 4 ? nil : { code: msg_record[:code], times: msg_record[:times] + 1 }
        @cache[msg_cache_key, 10.minutes] = tem_cache
        @code ||= 'WrongMsgCode' # 短信验证码错误
    end

    if !@code && @user.save
        session[:user_id] = @user.id # 注册后即登录
        @cache[msg_cache_key] = nil # 注册后删除缓存
        @code = :Success # 注册成功
        # try_send_vali_email '注册新账号'
    end
    @code ||= :Fail
    render :show, status: @user.id.nil? ? :unprocessable_entity : :created
  end

  # PATCH/PUT /index/users/1
  # PATCH/PUT /index/users/1.json
  def update
    @code = :Success if @user.update(index_user_params_update)

    respond_to do |format|
      if @code == :Success
        format.json { render :show, status: :ok, location: @user }
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
      else
        @code ||= :Fail
        format.json { render :show, status: :unprocessable_entity }
        format.html { render :edit }
      end
    end
  end

  # 修改密码
  def update_password
    new_password = params[:new_password] # 通过参数获取新密码
    @code = :Fail unless Validate::VALID_PASSWORD_REGEX.match(new_password) # 验证新密码是否合法

    render(json: { code: @code }) && return if @code # 用户未登录(@code==:NotLoggedIn)或者传入的新密码不合法

    # 判断修改方式, 支持原密码修改和短信验证码修改, 默认原密码修改
    case params[:update_type]
    when 'msg_code'
      @cache = Cache.new
      msg_cache_key = Valicode.msg_cache_key(@user.phone, 'update_password')
      msg_record = @cache[msg_cache_key] # 手机号验证码记录

      @code = 'WrongMsgCode' unless msg_record # 查询不到验证码记录

      # 当查询到验证码记录时通过参数获取新密码
      if msg_record && params[:msg_code] == msg_record[:code]
        @code = :Success if @user.update(password: new_password)
        @cache[msg_cache_key] = nil if @code == :Success # 清除缓存
      elsif msg_record
        # 重新设置缓存, 记录验证失败次数, 失败5次时, 验证码失效
        record_fail msg_record, msg_cache_key
      end
    # 默认原密码修改
    else
      old_password = params[:old_password] # 通过参数获取原密码
      user_password = BCrypt::Password.new(@user.password_digest) # 解码获取用户密码

      if user_password == old_password
        @code = :Success if @user.update(password: new_password)
      end
    end

    @code ||= :Fail
    render :show
  end

  # 修改手机号
  # 修改手机号需要两个验证,一个是旧手机号的验证码, 一个是新手机号和新手机号的验证码
  # 并且得保证新手机号没有被注册过, 否则修改失败
  def update_phone
    # 从参数中获取新手机号以及新旧手机号的验证码
    new_phone = params[:new_phone] # 新手机号
    new_msg_code = params[:new_msg_code] # 新手机号的验证码
    old_msg_code = params[:old_msg_code] # 旧手机号的验证码

    @code = 'PhoneAlreadyExist' if new_phone && Index::User.find_by_phone(new_phone) # 判断该手机号是否已被注册

    if !@code && new_phone && new_msg_code && old_msg_code
      # 从缓存中读取验证码记录
      @cache = Cache.new
      old_msg_cache_key = Valicode.msg_cache_key(@user.phone, 'update_phone')
      new_msg_cache_key = Valicode.msg_cache_key(new_phone, 'update_phone')

      old_msg_record = @cache[old_msg_cache_key] # 旧手机号验证码记录
      new_msg_record = @cache[new_msg_cache_key] # 新手机号验证码记录

      @code = 'WrongMsgCode' unless old_msg_record && new_msg_record # 查询不到验证码记录

      # 当查询到记录时 !@code = true 继续执行, 如果不做此判断将报错
      if !@code && old_msg_code == old_msg_record[:code] && new_msg_code == new_msg_record[:code]
        if @user.update(phone: new_phone) # 修改成功
          @code = :Success
          # 清空缓存记录
          @cache[new_msg_cache_key] = nil
          @cache[old_msg_cache_key] = nil
        end
      elsif !@code # 验证码错误且存在
        # 重新设置缓存, 记录验证失败次数, 失败5次时, 验证码失效
        record_fail old_msg_record, old_msg_cache_key
        record_fail new_msg_record, new_msg_cache_key
      end
    end

    @code ||= :Fail
    render :show
  end

  def update_email
    # 通过旧邮箱修验证更换邮箱的功能日后再实现
  end

  # 验证邮箱 目前即可通过这个动作实现验证又可实现修改，但修改无需旧邮箱验证，存在安全隐患
  def valid_email; end

  # 以下处理忘记密码和重置密码
  def reset_pwd; end

  # 检查用户名/邮箱/电话是否被注册
  def check_uniq
    uniq = nil
    val = params[:value]
    render(json: { uniq: nil }) && return if val.blank?

    case params[:name]
    when 'number'
      uniq = Index::User.find_by_number(val).nil? ? true : false
    when 'email'
      uniq = Index::User.find_by_email(val).nil? ? true : false
    when 'phone'
      uniq = Index::User.find_by_phone(val).nil? ? true : false
    end

    render json: { uniq: uniq }
  end

  def search
    cdt = params.slice(:number, :phone, :email)
    @users = Index::User.filter(cdt)
  end

  private

  # 新建时允许传入的参数
  def index_user_params
    params.require(:user).permit(:number, :password, :name, :phone, :email, :gender, :birthday, :address, :intro, :avatar)
  end

  # 更新时允许传入的参数
  def index_user_params_update
    params.require(:user).permit(:name, :gender, :birthday, :address, :intro, :avatar)
  end

  def record_fail(record, cache_key)
    # 为防止暴力破解, 同一条短信验证码最多允许验证失败5次
    # 修改旧手机号验证码记录
    tem_cache = record[:times] > 4 ? nil : { code: record[:code], times: record[:times] + 1 }
    @cache[cache_key, 10.minutes] = tem_cache
  end
end
