class AddDefaultsToIndexArticles < ActiveRecord::Migration
  def change
    change_column_default :index_articles, :is_deleted, false
  end
end
