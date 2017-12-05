json.code @code if @code
if @comment
  json.comment do
    json.extract! @comment, :id, :user_id, :content, :created_at, :updated_at
    json.reply_counts @comment.rep_counts || 0
    tf = @comment.thumb_up_info(@user)
    json.thumb_counts tf[:counts]
    json.has_thumb tf[:has]
  end
  json.errors @comment.errors if @comment.errors.any?
end
