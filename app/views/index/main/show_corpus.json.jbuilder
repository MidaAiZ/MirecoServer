json.code @code if @code
if @corpus
  # json.cache! @corpus.cache_key, expires_in: 3.minute do
    json.corpus do
      json.extract! @corpus, :id, :name, :tag, :created_at
      json.comment_counts @corpus.cmt_counts || 0
      tf = @corpus.thumb_up_info(@user)
      json.thumb_counts tf[:counts]
      json.has_thumb tf[:has]
    end
  # end
end
