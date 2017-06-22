class ChangeFilesAndRolesOnIsInner < ActiveRecord::Migration
  def change
    change_table :index_role_edits do |t|
      t.boolean :is_inner, default: false
    end
    change_table :index_articles do |t|
      t.remove :is_inner
    end
    change_table :index_folders do |t|
      t.remove :is_inner
      t.jsonb :files, default: {}
    end
    change_table :index_corpus do |t|
      t.remove :is_inner
      t.jsonb :files, default: {}
    end
    add_index :index_corpus, :files, name: :index_corpus_on_files, using: :gin
    add_index :index_folders, :files, name: :index_folder_on_files, using: :gin
  end
end
