json.code @code if @code
if @article
  # json.cache! @article.cache_key, expires_in: 3.minute do
    json.article do
      json.extract! @article, :id, :name, :tag, :created_at, :content
      json.comment_counts @article.cmt_counts || 0
      tf = @article.thumb_up_info(@user)
      json.thumb_counts tf[:counts]
      json.has_thumb tf[:has]
    end
  # end
end
