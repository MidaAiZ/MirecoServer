json.code @code if @code
if @article
  # json.cache! @article.cache_key, expires_in: 3.minute do
  json.article do
      json.extract! @article, :id, :name, :tag, :created_at, :updated_at, :cover, :read_times, :thumbs_count, :comments_count
      json.content @article.content.text
      json.editors do
        json.array! @editor_roles do |r|
            e = r.editor
            json.name e.number
            json.avatar e.avatar
            json.id e.id
            json.role r.name
        end
      end
      if @article.corpus_id
        json.corpus do
          cor = @article.corpus
          json.name cor.name
          json.id cor.id
        end
      end
    end
  # end
end
