json.code @code if @code
if @corpus
  json.corpus do
    json.extract! @corpus, :id, :name, :tag, :is_marked, :is_shown, :file_seed_id, :created_at, :updated_at
    json.folder_id @corpus.dir_id
  end
  json.errors @corpus.errors if @corpus.errors.any?
end
