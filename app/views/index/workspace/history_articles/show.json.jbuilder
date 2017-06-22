json.code @code if @code
if @history_article
  json.extract! @history_article, :id, :name, :tag, :content, :created_at
  json.errors @history_article.errors if @history_article.errors.any?
end
