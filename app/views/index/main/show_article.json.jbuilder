json.code @code if @code
if @article
  # json.cache! @article.cache_key, expires_in: 3.minute do
    json.article do
      json.extract! @article, :id, :name, :tag, :created_at, :content
      json.comments_count @article.cmt_counts || 0
      json.read_times @article.read_times
      json.editors_count @article.file_seed.editors_count
      tf = @article.thumb_up_info(@user)
      json.thumbs_count tf[:counts]
      json.has_thumb tf[:has]
      json.editors do
        json.array! @article.editor_roles do |r|
            e = r.editor
            json.name e.number
            json.avatar e.avatar
            json.id e.id
            json.role r.name
        end
      end
    end
  # end
end
