json.code @code if @code
if @edit_comment
  json.edit_comment do
  	json.extract! @edit_comment, :id, :user_id, :hash_key, :content, :created_at, :replies
  end
  json.errors @edit_comment.errors if @edit_comment.errors.any?
end
