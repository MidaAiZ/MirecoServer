class RenameIndexArticleThumbUpToLike < ActiveRecord::Migration[5.1]
  def change
    rename_table :index_article_thumb_ups, :index_article_likes
  end
end
