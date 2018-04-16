class AddDetailsToIndexArticles < ActiveRecord::Migration
  def change
    change_table :index_articles do |t|
      t.boolean :is_shown
      t.boolean :is_marked
      t.boolean :is_deleted
      t.boolean :is_inner, default: true

      t.references :index_folder
    end
  end
end
