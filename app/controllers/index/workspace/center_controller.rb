class Index::Workspace::CenterController < IndexController
  before_action :check_login

  def index
    if @user
      count = params[:count] || 15
      page = params[:page] || 1

      @nonpaged_edit_roles = @user.edit_roles.includes(file_seed: :root_file)
      @edit_roles = @nonpaged_edit_roles.page(page).per(count)
    end
  end

  private
end
