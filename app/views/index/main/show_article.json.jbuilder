if @article
  json.article do
    json.extract! @article, :id, :name, :tag, :created_at, :content
    json.has_thumb @user.nil? ? false : @article.has_thumb_up?(@user)
  end
end
