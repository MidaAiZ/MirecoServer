class AddCoverToIndexArticleAndCorpus < ActiveRecord::Migration[5.1]
  def change
    add_column :index_articles, :cover, :string
    add_column :index_corpus, :cover, :string
  end
end
