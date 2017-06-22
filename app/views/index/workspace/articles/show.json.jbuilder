json.code @code if @code
if @article
  json.article do
    json.extract! @article, :id, :name, :tag, :is_shown, :is_marked, :created_at, :updated_at, :content
    json.folder_id @article.dir_id if @article.dir_type == 'Index::Workspace::Folder'
    json.corpus_id @article.dir_id if @article.dir_type == 'Index::Workspace::Corpus'
  end
  json.errors @article.errors if @article.errors.any?
end
