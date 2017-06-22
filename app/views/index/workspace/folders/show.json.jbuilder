json.code @code if @code
if @folder
  json.folder do
    json.extract! @folder, :id, :name, :tag, :is_shown, :is_marked, :file_seed_id, :created_at, :updated_at
    json.folder_id @folder.dir_id
  end
  json.errors @folder.errors if @folder.errors.any?
end
