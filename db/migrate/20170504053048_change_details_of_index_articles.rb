class ChangeDetailsOfIndexArticles < ActiveRecord::Migration
  def change
    change_table :index_articles do |t|
      t.rename :title, :name
      change_column_default :index_articles, :is_inner, false
    end
  end
end
