json.comments do
  json.array! @comments do |c|
    json.call(c, :id, :user_id, :content, :created_at)
  end
end
