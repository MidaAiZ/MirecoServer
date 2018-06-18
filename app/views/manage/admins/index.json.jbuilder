json.counts @counts
json.admins do
  json.cache! @admins, expires_in: 3.minutes do
    @admins.each do |admin|
      u.tel[3..6] = "****"
      u.mail[0..3] = "****" unless admin.mail.blank?
      json.call(admin, :id, :name, :number, :avatar, :tel, :mail, :address, :birthday, :created_at, :updated_at)
    end
  end
end
