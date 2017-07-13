json.counts @counts
json.folders do
  json.array! @folders do |f|
    json.call(f, :id, :name, :tag, :is_shown, :is_marked, :created_at, :updated_at)
    json.folder_id f.dir_id
    # json.editors_count f.editor_roles.size
  end
end
