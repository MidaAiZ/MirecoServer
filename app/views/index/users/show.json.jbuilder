json.code @code if @code
@user.phone[3..6] = "****"
@user.email[0..3] = "****" unless @user.email.blank?
json.extract! @user, :id, :number, :phone, :email, :address, :birthday
json.avatar @user.avatar.url
json.errors @user.errors if @user.errors.any?
