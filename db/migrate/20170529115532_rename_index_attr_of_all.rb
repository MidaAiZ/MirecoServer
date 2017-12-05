class RenameIndexAttrOfAll < ActiveRecord::Migration[4.2]
  def change
    remove_column :index_articles, :index_user_id
    remove_column :index_corpus, :index_user_id
    remove_column :index_folders, :index_user_id
    rename_column :index_history_articles, :index_article_id, :article_id
    rename_column :index_role_edits, :index_user_id, :user_id
  end
end
