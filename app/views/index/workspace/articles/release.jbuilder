json.code @code if @code
if @release
  json.article do
    json.extract! @release, :id, :name, :created_at, :updated_at, :cover, :read_times, :thumbs_count, :comments_count  # else
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
