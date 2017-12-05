class AddForeignkeyToIndexArticles < ActiveRecord::Migration[4.2]
  def change
    change_table :index_articles do |t|
      t.references :index_corpus, foreign_keys: true, index: true
    end
  end
end
