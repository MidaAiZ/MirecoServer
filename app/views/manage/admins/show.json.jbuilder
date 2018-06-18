json.code @code if @code
json.user do
  @admin.tel[3..6] = "****"
  @admin.mail[0..3] = "****" unless @admin.mail.blank?
  json.extract! @admin, :id, :number, :name, :tel, :mail, :avatar, :created_at, :updated_at
end
json.errors @admin.errors if @admin.errors.any?
