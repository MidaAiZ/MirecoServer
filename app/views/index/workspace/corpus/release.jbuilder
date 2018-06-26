json.code @code if @code
if @release
  json.corpus do
    json.extract! @release, :id, :name, :created_at, :updated_at, :cover, :read_times, :likes_count, :comments_count  # else
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
