json.code @code if @code
if @comment
  json.comment do
    json.extract! @comment, :id, :content, :created_at, :updated_at
    json.reply_counts @comment.rep_counts || 0
    tf = @comment.thumb_up_info(@user)
    json.thumb_counts tf[:counts]
    json.has_thumb tf[:has]
    json.user do
      json.call(@comment.user, :id, :number, :avatar)
    end
    json.replies do
      json.array! @replies do |r|
        json.call(r, :id, :content, :created_at)
        json.user do
            json.call(r.user, :id, :number, :avatar)
        end
        # tf = r.thumb_up_info(@user)
        # json.thumb_counts tf[:counts]
        # json.has_thumb tf[:has]
      end
    end

  end
  json.errors @comment.errors if @comment.errors.any?
end
