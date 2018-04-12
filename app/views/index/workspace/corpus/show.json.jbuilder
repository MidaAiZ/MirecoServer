json.code @code if @code
if @corpus
  json.corpus do
    json.extract! @corpus, :id, :name, :tag, :is_shown, :file_seed_id, :created_at, :updated_at, :cover, :file_seed_id
    json.folder_id @corpus.dir_id
    json.is_marked @corpus.is_marked @user.id
  end
  json.errors @corpus.errors if @corpus.errors.any?
end
