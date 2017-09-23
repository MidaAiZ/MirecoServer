json.corpuses do
  json.cache! @corpuses, expires_in: 3.minutes do
    json.cache_collection! @corpuses, expires_in: 3.minutes do |c|
      json.call(c, :id, :name, :tag, :is_shown, :is_marked, :created_at, :updated_at)
      json.comment_counts c.cmt_counts || 0
      # json.editors_count c.editor_roles.size
      tf = c.thumb_up_info(@user)
      json.thumb_counts tf[:counts]
      json.has_thumb tf[:has]
    end
  end
end
