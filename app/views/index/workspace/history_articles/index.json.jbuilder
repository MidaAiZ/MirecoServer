json.history_articles do
  json.array! @history_articles do |h|
    json.call(h, :id, :name, :tag, :created_at)
  end
end
