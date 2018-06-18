json.counts @counts
json.users do
  json.cache! @users, expires_in: 3.minutes do
    @users.each do |u|
      u.phone[3..6] = "****"
      u.email[0..3] = "****" unless u.email.blank?
      json.call(u, :id, :number, :name, :avatar, :phone, :email, :address, :birthday, :created_at, :updated_at)
    end
  end
end
