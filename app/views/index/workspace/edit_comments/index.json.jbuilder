json.comments do
  json.array! @edit_comments do |e|
    json.call(e, :id, :hash_key, :content, :created_at)
    json.user do
      json.call(e.user, :id, :name, :number, :avatar)
    end
    json.replies do
      json.array! e.replies do |r|
        json.call(r, :id, :content)
        json.user do
          json.call(r.user, :id, :name, :number, :avatar)
        end
      end 
    end
  end
end
