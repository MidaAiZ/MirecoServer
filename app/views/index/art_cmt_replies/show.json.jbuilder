json.code @code if @code
if @reply
  json.reply do
  	json.extract! @reply, :id, :comment_id, :user_id, :content, :created_at, :likes_count, :is_like
    # json.has_like tf[:has]
    json.user do
      u = @reply.user
      json.number u.number
      json.avatar u.avatar
    end
  end
  json.errors @reply.errors if @reply.errors.any?
end
