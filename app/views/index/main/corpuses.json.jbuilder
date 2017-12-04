json.counts @counts
json.corpuses do
  json.cache! @corpuses, expires_in: 3.minutes do
    json.cache_collection! @corpuses, expires_in: 3.minutes do |c|
      json.call(c, :id, :name, :tag, :created_at, :updated_at)
      json.comments_count c.cmt_counts || 0
      json.read_times c.read_times || 0
      json.editors_count c.file_seed.editors_count
      tf = c.thumb_up_info(@user)
      json.thumbs_count tf[:counts]
      json.has_thumb tf[:has]
      json.editor do
        editor = c.own_editor
        json.name editor.number
        json.avatar editor.avatar
        json.id editor.id
      end
    end
  end
end
