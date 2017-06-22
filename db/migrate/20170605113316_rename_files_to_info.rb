class RenameFilesToInfo < ActiveRecord::Migration
  def change
    change_table :index_folders do |t|
      t.rename :files, :info
    end
    change_table :index_corpus do |t|
      t.rename :files, :info
    end
    change_table :index_articles do |t|
      t.jsonb :info, default: {}
    end
    add_index :index_articles, :info, name: :index_corpus_on_info, using: :gin
  end
end
