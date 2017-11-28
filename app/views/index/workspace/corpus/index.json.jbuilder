json.counts @counts
json.corpuses do
  json.array! @corpuses do |c|
    json.call(c, :id, :name, :tag, :is_shown, :created_at, :updated_at)
    json.folder_id c.dir_id
    json.is_marked c.is_marked @user.id
    # json.editors_count c.editor_roles.size
  end
end
