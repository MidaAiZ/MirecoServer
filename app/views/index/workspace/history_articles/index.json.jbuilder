json.historys do
  json.array! @history_articles do |h|
    json.call(h, :id, :name, :tag, :created_at, :content, :diff)
    json.editor do
      json.call(h.editor, :id, :name, :number)
    end
  end
end
