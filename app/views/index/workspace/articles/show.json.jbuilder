json.code @code if @code
if @article
  json.article do
    json.extract! @article, :id, :name, :tag, :is_shown, :created_at, :updated_at
    json.folder_id @article.dir_id if @article.dir_type == 'Index::Workspace::Folder'
    json.corpus_id @article.dir_id if @article.dir_type == 'Index::Workspace::Corpus'
    json.is_marked @article.is_marked @user.id
    json.content @article.content.text
    json.config @article.get_config(@user.id)
  end
  json.errors @article.errors if @article.errors.any?
end
