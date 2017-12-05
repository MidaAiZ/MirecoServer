class AddIndexToIndexFileSeedSources < ActiveRecord::Migration[4.2]
  def change
      add_index :index_articles, :index_file_seed_id
      add_index :index_corpus, :index_file_seed_id
      add_index :index_folders, :index_file_seed_id
      add_index :index_role_edits, :index_file_seed_id
  end
end
