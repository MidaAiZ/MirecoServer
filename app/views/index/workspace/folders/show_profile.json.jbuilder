json.code @code
if @code == 'Success'
  json.son_folders do
    json.array! @son_folders do |f|
      json.folder do
        json.call(f, :id, :name, :tag, :is_shown, :is_marked, :is_deleted, :created_at, :updated_at)
        json.folder_id f.dir_id
        # json.editors_count f.editor_roles.size
      end
    end
  end

  json.son_corpus do
    json.array! @son_corpuses do |c|
      json.corpus do
        json.call(c, :id, :name, :tag, :is_shown, :is_marked, :created_at, :updated_at)
        json.folder_id c.dir_id
        # json.editors_count c.editor_roles.size
      end
    end
  end

  json.son_articles do
    json.array! @son_articles do |a|
      json.article do
        json.call(a, :id, :name, :tag, :is_shown, :is_marked, :created_at, :updated_at)
        json.folder_id a.dir_id if a.dir_type == 'Index::Workspace::Folder'
        json.corpus_id a.dir_id if a.dir_type == 'Index::Workspace::Corpus'
        # json.editors_count a.editor_roles.size
      end
    end
  end

  # json.father_folder do
  #   json.partial! 'index/folders/index_folder', index_folder: @father_folder if @father_folder
  # end
end
