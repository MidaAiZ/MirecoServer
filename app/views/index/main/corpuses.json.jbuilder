json.counts @counts
json.corpuses do
  json.cache! @corpuses, expires_in: 3.minutes do
    json.cache_collection! @corpuses, expires_in: 3.minutes do |c|
      json.call(c, :id, :name, :tag, :created_at, :updated_at, :cover, :read_times, :likes_count, :comments_count)
      json.editor do
        editor = c.author
        json.name editor.number
        json.avatar editor.avatar
        json.id editor.id
      end
    end
  end
end
