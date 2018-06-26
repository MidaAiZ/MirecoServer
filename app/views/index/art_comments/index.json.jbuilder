json.comments do
  json.array! @comments do |c|
    json.call(c, :id, :user_id, :article_id, :content, :created_at, :likes_count, :replies_count, :is_like)
    json.user do
      u = c.user
      json.number u.number
      json.avatar u.avatar
    end
  end
end
