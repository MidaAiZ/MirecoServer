json.comments do
  json.array! @edit_comments do |e|
    json.call(e, :id, :user_id, :hash_key, :content, :created_at, :replies)
  end
end
