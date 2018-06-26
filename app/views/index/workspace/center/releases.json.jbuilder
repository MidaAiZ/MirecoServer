json.articles do
  json.array! @files do |f|
    json.call(f, :file_type, :id, :name, :tag, :created_at, :updated_at, :cover, :read_times, :likes_count, :comments_count)
  end
  # json.editors_count a.file_seed.editors_count
end
