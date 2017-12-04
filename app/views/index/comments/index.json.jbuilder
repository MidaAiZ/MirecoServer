json.comments do
  json.array! @comments do |c|
    json.call(c, :id, :content, :created_at)
    json.reply_counts c.rep_counts || 0
    tf = c.thumb_up_info(@user)
    json.thumb_counts tf[:counts]
    json.has_thumb tf[:has]
    json.user do
      json.call(c.user, :id, :number, :avatar)
      # tf = r.thumb_up_info(@user)
      # json.thumb_counts tf[:counts]
      # json.has_thumb tf[:has]
    end
  end
end
