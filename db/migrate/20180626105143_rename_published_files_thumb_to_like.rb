class RenamePublishedFilesThumbToLike < ActiveRecord::Migration[5.1]
  def change
    rename_column :index_published_articles, :thumbs_count_cache, :likes_count_cache
    rename_column :index_published_corpus, :thumbs_count_cache, :likes_count_cache
  end
end
