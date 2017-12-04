json.code @code if @code
if @reply
  json.reply do
  	json.extract! @reply, :id, :content, :created_at
    tf = @reply.thumb_up_info(@user)
    json.thumb_counts tf[:counts]
    json.has_thumb tf[:has]
    json.user do
      json.call(@reply.user, :id, :number, :avatar)
      # tf = r.thumb_up_info(@user)
      # json.thumb_counts tf[:counts]
      # json.has_thumb tf[:has]
    end
  end
  json.errors @reply.errors if @reply.errors.any?
end
