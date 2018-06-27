json.articles do
  json.array! @articles do |a|
    json.id a.origin_id
    json.release_id a.id
    json.call(a, :name, :tag, :corpus_id, :created_at, :updated_at, :cover, :read_times, :likes_count, :comments_count)
  end
  # json.editors_count a.file_seed.editors_count
end
