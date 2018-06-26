json.counts @counts
json.files do
  json.cache! @files, expires_in: 3.minutes do
    json.cache_collection! @files, expires_in: 3.minutes do |c|
      json.call(c, :id, :name, :tag, :state, :created_at, :updated_at, :cover, :read_times, :likes_count, :comments_count, :origin_id)
      json.editor do
        editor = c.author
        json.name editor.number
        json.avatar editor.avatar
        json.id editor.id
      end
    end
  end
end
