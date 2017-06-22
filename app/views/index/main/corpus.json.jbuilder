json.corpuses do
  json.array! @corpuses do |c|
    json.call(c, :id, :name, :tag, :created_at, :updated_at)
    json.has_thumb @user.nil? ? false : c.has_thumb_up?(@user)
  end
end
