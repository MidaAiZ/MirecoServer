json.comments do
  json.array! @comments do |c|
    json.call(c, :id, :user_id, :content, :created_at)
    json.reply_counts c.rep_counts || 0
    tf = c.thumb_up_info(@user)
    json.thumb_counts tf[:counts]
    json.has_thumb tf[:has]

    json.replies do
      json.array! c.limit_3_replies do |r|
        json.call(r, :id, :user_id, :content, :created_at)
        # tf = r.thumb_up_info(@user)
        # json.thumb_counts tf[:counts]
        # json.has_thumb tf[:has]
      end
    end
  end
end
