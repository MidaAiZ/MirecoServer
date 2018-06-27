json.code @code if @code
if @release
  json.release do
    json.extract! @release, :id, :origin_id, :name, :created_at, :updated_at, :cover, :read_times, :likes_count, :comments_count, :corpus_id
    json.editors do
      json.array! @editor_roles do |r|
          e = r.editor
          json.name e.number
          json.avatar e.avatar
          json.id e.id
          json.role r.name
      end
    end
    if @release.corpus_id
      json.corpus do
        cor = @release.corpus
        json.name cor.name
        json.id cor.id
      end
    end
    json.content @release.content.text
  end
end
