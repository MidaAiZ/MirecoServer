json.corpuses do
  json.cache! @corpuses, expires_in: 3.minutes do
    json.cache_collection! @corpuses, expires_in: 3.minutes do |c|
      json.call(c, :id, :name, :tag, :is_shown, :created_at, :updated_at, :cover)
      json.is_marked c.is_marked @user.id
    end
  end
end
