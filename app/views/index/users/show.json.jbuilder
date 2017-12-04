json.code @code if @code
  json.user do
    @user.phone[3..6] = "****"
    @user.email[0..3] = "****" unless @user.email.blank?
    json.extract! @user, :id, :number, :phone, :email, :address, :birthday, :gender
    json.avatar @user.avatar.url
  end
json.errors @user.errors if @user.errors.any?
