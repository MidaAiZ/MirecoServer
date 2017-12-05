class AddDefaultsToIndexArticles < ActiveRecord::Migration[4.2]
  def change
    change_column_default :index_articles, :is_deleted, false
  end
end
