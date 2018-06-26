json.replies do
  json.array! @replies do |r|
    json.call(r, :id, :comment_id, :user_id, :content, :created_at, :likes_count, :is_like)
    # json.has_like tf[:has]
    json.user do
      u = r.user
      json.number u.number
      json.avatar u.avatar
    end
  end
end
