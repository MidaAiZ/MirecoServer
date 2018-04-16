class CreateIndexHistoryArticles < ActiveRecord::Migration
  def change
    create_table :index_history_articles do |t|
      t.string :title
      t.text :content
      t.string :tag
      t.references :index_article

      t.timestamps null: false
    end
  end
end
