class CreateIndexArticles < ActiveRecord::Migration
  def change
    create_table :index_articles do |t|
      t.string :title
      t.text :content
      t.string :tag
      t.references :index_user

      t.timestamps null: false
    end
  end
end
