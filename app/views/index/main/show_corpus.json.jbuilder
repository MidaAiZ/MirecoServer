json.code @code if @code
if @corpus
  # json.cache! @corpus.cache_key, expires_in: 3.minute do
    json.corpus do
      json.extract! @corpus, :id, :name, :tag, :created_at
      json.comments_count @corpus.cmt_counts || 0
      json.read_times @corpus.read_times || 0
      json.editors_count @corpus.file_seed.editors_count
      tf = @corpus.thumb_up_info(@user)
      json.thumbs_count tf[:counts]
      json.has_thumb tf[:has]
      json.editors do
        json.array! @corpus.editor_roles do |r|
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
