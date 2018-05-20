json.code @code if @code
if @history_article
  json.extract! @history_article, :id, :name, :tag, :content, :created_at, :content, :diff
  json.editor do
    json.call(@history_article.editor, :id, :name, :number)
  end
  json.errors @history_article.errors if @history_article.errors.any?
end
