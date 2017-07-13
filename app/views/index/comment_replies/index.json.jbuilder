json.replies do
  json.array! @replies do |r|
    json.call(r, :id, :user_id, :content, :created_at)
    tf = r.thumb_up_info(@user)
    json.thumb_counts tf[:counts]
    json.has_thumb tf[:has]
  end
end
