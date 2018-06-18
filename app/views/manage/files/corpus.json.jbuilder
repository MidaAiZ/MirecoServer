json.code @code if @code
if @file
  # json.cache! @article.cache_key, expires_in: 3.minute do
  json.article do
      json.extract! @file, :id, :name, :tag, :state, :created_at, :updated_at, :cover, :read_times, :thumbs_count, :comments_count, :origin_id
      json.editors do
        json.array! @editor_roles do |r|
            e = r.editor
            json.name e.number
            json.avatar e.avatar
            json.id e.id
            json.role r.name
        end
      end
    end
  # end
end
