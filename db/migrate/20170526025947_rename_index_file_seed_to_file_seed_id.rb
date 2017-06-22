class RenameIndexFileSeedToFileSeedId < ActiveRecord::Migration
  def change
    rename_column :index_articles, :index_file_seed_id, :file_seed_id
    rename_column :index_corpus, :index_file_seed_id, :file_seed_id
    rename_column :index_folders, :index_file_seed_id, :file_seed_id
    rename_column :index_role_edits, :index_file_seed_id, :file_seed_id
    rename_index "index_role_edits", "index_index_role_edits_on_file_seed_id", "index_role_edits_on_file_seed_id"
    rename_index "index_folders", "index_index_folders_on_file_seed_id", "index_folders_on_file_seed_id"
    rename_index "index_corpus", "index_index_corpus_on_file_seed_id", "index_corpus_on_file_seed_id"
    rename_index "index_articles", "index_index_articles_on_file_seed_id", "index_articles_on_file_seed_id"
  end
end
