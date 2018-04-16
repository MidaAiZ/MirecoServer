class AddIndexToIndexFiles < ActiveRecord::Migration
  def change
    add_index :index_articles, :name, name: :index_articles_on_name
    add_index :index_corpus, :name, name: :index_corpus_on_name
    add_index :index_folders, :name, name: :index_folders_on_name

    add_index :index_articles, :tag, name: :index_articles_on_tag
    add_index :index_corpus, :tag, name: :index_corpus_on_tag
  end
end
