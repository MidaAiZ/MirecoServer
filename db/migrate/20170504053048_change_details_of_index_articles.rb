class ChangeDetailsOfIndexArticles < ActiveRecord::Migration[4.2]
  def change
    change_table :index_articles do |t|
      t.rename :title, :name
      change_column_default :index_articles, :is_inner, false
    end
  end
end
