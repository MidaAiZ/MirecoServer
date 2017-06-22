json.articles do
  json.array! @articles do |a|
    json.call(a, :id, :name, :tag, :is_shown, :is_marked, :created_at, :updated_at)
    json.folder_id a.dir_id if a.dir_type == 'Index::Workspace::Folder'
    json.corpus_id a.dir_id if a.dir_type == 'Index::Workspace::Corpus'
    # json.editors_count a.editor_roles.size
  end
end
