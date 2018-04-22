json.articles do
  json.cache! @articles, expires_in: 3.minutes do
    json.cache_collection! @articles, expires_in: 3.minutes do |a|
      json.call(a, :id, :name, :tag, :is_shown, :created_at, :updated_at, :cover)
      json.is_marked a.is_marked @user.id
      json.editors_count a.file_seed.editors_count
    end
  end
end
