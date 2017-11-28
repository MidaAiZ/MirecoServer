json.array! @son_articles do |a|
  json.article do
    json.call(a, :id, :name, :tag, :is_shown, :created_at, :updated_at)
    json.folder_id a.dir_id if a.dir_type == 'Index::Workspace::Folder'
    json.corpus_id a.dir_id if a.dir_type == 'Index::Workspace::Corpus'
    json.is_marked a.is_marked @user.id
  end
end
