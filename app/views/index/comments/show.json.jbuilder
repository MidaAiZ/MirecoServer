json.code @code if @code
if @comment
  json.comment do
    json.extract! @comment, :id, :user_id, :content, :created_at, :updated_at
    json.replies do
      json.array! @replies do |r|
        json.call(r, :id, :user_id, :content, :created_at)
      end
    end
  end
  json.errors @comment.errors if @comment.errors.any?
end
