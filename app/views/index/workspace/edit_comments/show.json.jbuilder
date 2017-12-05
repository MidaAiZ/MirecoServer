json.code @code if @code
if @edit_comment
  Index::Workspace::EditComment.include_users [@edit_comment]
  json.edit_comment do
  	json.extract! @edit_comment, :id, :hash_key, :content, :created_at, :replies
    json.user do
        json.call(@edit_comment.user, :id, :name, :number, :avatar)
    end
  end
  json.errors @edit_comment.errors if @edit_comment.errors.any?
end
