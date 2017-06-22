json.articles do
  json.array! @articles do |a|
    json.call(a, :id, :name, :tag, :created_at)
    json.has_thumb @user.nil? ? false : a.has_thumb_up?(@user)
  end
end
