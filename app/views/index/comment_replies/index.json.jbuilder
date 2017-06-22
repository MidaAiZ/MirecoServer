json.replies do
  json.array! @replies do |r|
    json.call(r, :id, :user_id, :content, :created_at)
  end
end
