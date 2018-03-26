json.code @code if @code
if @trash && @trash.id
  json.trash do
    json.extract! @trash, :id, :files_count, :created_at, :file_id, :file_name
    json.file_type file_type =
                     case @trash.file_type
                     when 'Index::Workspace::Article'
                       'articles'
                     when 'Index::Workspace::Folder'
                       'folders'
                     when 'Index::Workspace::Corpus'
                       'corpuses'
                     end
  end
end
