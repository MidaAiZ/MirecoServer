json.code @code if @code
if @folder
  json.folder do
    json.extract! @folder, :id, :name, :tag, :is_shown, :file_seed_id, :created_at, :updated_at
    json.folder_id @folder.dir_id
    json.is_marked @folder.is_marked @user.id
  end
  json.errors @folder.errors if @folder.errors.any?
end
