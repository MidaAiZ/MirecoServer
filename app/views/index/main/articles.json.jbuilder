json.count @count
json.articles do
  json.cache! @articles, expires_in: 3.minutes do
    json.cache_collection! @articles, expires_in: 3.minutes do |a|
      json.call(a, :id, :name, :tag, :created_at, :updated_at, :cover, :read_times, :likes_count, :comments_count, :is_like)
      json.editor do
        editor = a.author
        json.name editor.number
        json.avatar editor.avatar
        json.id editor.id
      end
    end
  end
end
