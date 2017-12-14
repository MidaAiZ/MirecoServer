json.code @code if @code
if @edit_comment
  json.edit_comment do
    json.extract! @edit_comment, :id, :hash_key, :content, :created_at
    json.replies do
      json.array! @replies do |r|
        json.call(r, :id, :content)
        json.user do
          json.call(r.user, :id, :name, :number, :avatar)
        end
      end
    end
    json.user do
        json.call(@edit_comment.user, :id, :name, :number, :avatar)
    end
  end
  json.errors @edit_comment.errors if @edit_comment.errors.any?
end
