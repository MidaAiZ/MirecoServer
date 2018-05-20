class AddDiffToIndexArticlesHistory < ActiveRecord::Migration[5.1]
  def change
    add_column :index_history_articles, :diff, :string
  end
end
