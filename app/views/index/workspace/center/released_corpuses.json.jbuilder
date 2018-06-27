json.corpuses do
  json.array! @corpuses do |c|
    json.id c.origin_id
    json.release_id c.id
    json.call(c, :id, :name, :tag, :is_shown, :created_at, :updated_at, :cover, :read_times, :likes_count, :comments_count)
  end
end
