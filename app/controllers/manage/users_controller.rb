class Manage::UsersController < ManageController
  before_action :set_user, except: [:index]

  def index
    @users = Index::User.page(params[:page]).per(params[:count])
  end

  def show

  end

  def update
    @code = @user.update(update_user_params) ? :Success : :Fail
    do_response
  end

  def forbid
    @code = @user.forbid ? :Success : :Fail
    do_response
  end

  def recover
    @code = @user.recover ? :Success : :Fail
    do_response
  end

  private

  def set_user
    @user = Index::User.fetch params[:id]
    render(json: { code: :ResourceNotExist }) && return unless @user
  end

  def update_user_params
    params.require(:user).permit(:name, :password, :phone, :email, :address, :birthday)
  end

  def do_response
    respond_to do |format|
      if @code == :Success
        format.json { render :show, status: 200}
      else
        format.json { render json: { code: @code, errors: @user.errors }, status: :unprocessable_entity}
      end
    end
  end
end
