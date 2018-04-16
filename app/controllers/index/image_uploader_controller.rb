class Index::ImageUploaderController < IndexController
  before_action :require_login

  # POST /index/articles
  # POST /index/articles.json
  def create
   @image = Index::UserImage.new(file: image_params)
   @image.user = @user
   @image.save

   if @image.id
     render :show, status: 200
   else
     render json: {code: :Fail, errors: @image.errors}, status: :unprocessable_entity
   end
  end

  private

  def image_params
    params.require(:file)
  end
end
