json.trashes do
  json.array! @trashes do |t|
    json.call(t, :id, :files_count, :created_at, :file_id, :file_name)
    json.file_type file_type =
                     case t.file_type
                     when 'Index::Workspace::Article'
                       'articles'
                     when 'Index::Workspace::Folder'
                       'folders'
                     when 'Index::Workspace::Corpus'
                       'corpuses'
                     end
  end
end
