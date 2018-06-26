json.code @code if @code
if @comment
  json.comment do
    json.extract! @comment, :id, :user_id, :article_id, :content, :created_at, :likes_count, :replies_count, :is_like
    # json.has_like tf[:has]
    json.user do
      u = @comment.user
      json.number u.number
      json.avatar u.avatar
    end
  end
  json.errors @comment.errors if @comment.errors.any?
end
