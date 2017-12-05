class ChangeFatherFilesRefOfIndexArticles < ActiveRecord::Migration[4.2]
  def change
    change_table :index_articles do |t|
      t.remove :index_folder_id
      t.remove :index_corpus_id
      t.references :dir, :polymorphic => true
    end
    add_index "index_articles", ["dir_type", "dir_id"], name: "index_article_on_dir_type_id"
  end
end
