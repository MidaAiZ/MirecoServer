class ChangeTitleToNameOfIndexHistoryArticles < ActiveRecord::Migration
  def change
    change_table :index_history_articles do |t|
      t.rename :title, :name
    end
  end
end
