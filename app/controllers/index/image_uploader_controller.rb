class Index::ImageUploaderController < IndexController
  before_action :require_login

  # POST /index/articles
  # POST /index/articles.json
  def create
   @image = Index::UserImage.new(file: params[:file])
   @image.user = @user
   @image.save

   if @image.id
     render :show, status: :created
   else
     render json: {code: :Fail, errors: @image.errors}, status: :unprocessable_entity
   end
  end


  def get_upload_tocken
    # key = @user.id.to_s + (params[:file_name] || "") # 上传到七牛后保存的文件名
    uptoken = _create_upload_tocken(nil)

    render json: {code: @code, uptoken: uptoken}
  end

  private

  def image_params
    params.require(:file).permit(:name)
  end

  def _create_upload_tocken key
    # 要上传的空间
    bucket = 'mireco-server-public'
    # 构建上传策略，上传策略的更多参数请参照 http://developer.qiniu.com/article/developer/security/put-policy.html
    put_policy = Qiniu::Auth::PutPolicy.new(
        bucket, # 存储空间
        key,    # 指定上传的资源名，如果传入 nil，就表示不指定资源名，将使用默认的资源名
        720    # token 过期时间，默认为 3600 秒，即 1 小时
    )
    # 生成上传 Token
    Qiniu::Auth.generate_uptoken(put_policy)
  end
end
