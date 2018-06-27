json.code @code if @code
if @release
  json.corpus do
    json.extract! @release, :id, :origin_id, :name, :created_at, :updated_at, :cover, :read_times, :likes_count, :comments_count  # else
    json.articles do
      json.array! @articles do |a|
        json.extract! a, :id, :origin_id, :name, :created_at, :updated_at, :cover, :read_times, :likes_count, :comments_count, :corpus_id
      end
    end
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
end
