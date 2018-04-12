json.counts @counts
json.folders do
  json.array! @folders do |f|
    json.call(f, :id, :name, :tag, :is_shown, :created_at, :updated_at, :file_seed_id)
    json.folder_id f.dir_id
    json.is_marked f.is_marked @user.id
    # json.editors_count f.editor_roles.size
  end
end
