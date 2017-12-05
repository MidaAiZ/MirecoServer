class ChangeTitleToNameOfIndexHistoryArticles < ActiveRecord::Migration[4.2]
  def change
    change_table :index_history_articles do |t|
      t.rename :title, :name
    end
  end
end
