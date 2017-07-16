json.counts @counts
json.articles do
  json.cache! @articles, expires_in: 3.minutes do
    json.cache_collection! @articles, expires_in: 3.minutes do |a|
      json.call(a, :id, :name, :tag, :created_at, :updated_at)
      json.comment_counts a.cmt_counts || 0
      json.read_times a.read_times
      tf = a.thumb_up_info(@user)
      json.thumb_counts tf[:counts]
      json.has_thumb tf[:has]
    end
  end
end
