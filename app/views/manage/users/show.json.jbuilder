json.code @code if @code
@user && json.user do
  @user.phone[3..6] = "****"
  @user.email[0..3] = "****" unless @user.email.blank?
  json.extract! @user, :id, :number, :name, :phone, :email, :address, :birthday, :avatar, :created_at, :updated_at
end
json.errors @user.errors if @user && @user.errors.any?
