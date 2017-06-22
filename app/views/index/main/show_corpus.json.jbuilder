json.corpus do
  json.extract! @corpus, :id, :name, :tag, :created_at
  json.has_thumb @user.nil? ? false : @corpus.has_thumb_up?(@user)
end
