json.code @code if @code
if @reply
  json.reply do
  	json.extract! @reply, :id, :user_id, :content, :created_at
  end
  json.errors @reply.errors if @reply.errors.any?
end
