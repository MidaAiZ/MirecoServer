json.comments do
  json.array! @edit_comments do |e|
    json.call(e, :id, :hash_key, :content, :created_at, :replies)
    json.user do
        json.call(e.user, :id, :name, :number, :avatar)
    end
  end
end
