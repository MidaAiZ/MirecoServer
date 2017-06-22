json.corpuses do
  json.array! @corpuses do |c|
    json.call(c, :id, :name, :tag, :is_shown, :is_marked, :created_at, :updated_at)
    json.folder_id c.dir_id
    # json.editors_count c.editor_roles.size
  end
end
