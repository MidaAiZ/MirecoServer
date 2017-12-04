json.counts @counts
json.articles do
  json.cache! @articles, expires_in: 3.minutes do
    json.cache_collection! @articles, expires_in: 3.minutes do |a|
      json.call(a, :id, :name, :tag, :created_at, :updated_at)
      json.comments_count a.cmt_counts || 0
      json.read_times a.read_times
      json.editors_count a.file_seed.editors_count
      tf = a.thumb_up_info(@user)
      json.thumbs_count tf[:counts]
      json.has_thumb tf[:has]
      json.editor do
        editor = a.own_editor
        json.name editor.number
        json.avatar editor.avatar
        json.id editor.id
      end
    end
  end
end
