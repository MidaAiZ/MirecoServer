json.array! @son_articles do |a|
  json.call(a, :id, :name, :tag, :is_shown, :created_at, :updated_at, :cover, :file_seed_id)
  json.folder_id a.dir_id if a.dir_type == 'Index::Workspace::Folder'
  json.corpus_id a.dir_id if a.dir_type == 'Index::Workspace::Corpus'
  json.editors_count a.file_seed.editors_count
  json.is_marked a.is_marked @user.id
end
