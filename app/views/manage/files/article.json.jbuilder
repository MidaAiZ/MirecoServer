json.code @code if @code
if @file
  # json.cache! @file.cache_key, expires_in: 3.minute do
  json.file do
      json.extract! @file, :id, :name, :tag, :state, :created_at, :updated_at, :cover, :read_times, :thumbs_count, :comments_count, :origin_id
      json.content @file.content.text
      json.editors do
        json.array! @editor_roles do |r|
            e = r.editor
            json.name e.number
            json.avatar e.avatar
            json.id e.id
            json.role r.name
        end
      end
      if @file.corpus_id
        json.corpus do
          cor = @file.corpus
          json.name cor.name
          json.id cor.id
        end
      end
    end
  # end
end
