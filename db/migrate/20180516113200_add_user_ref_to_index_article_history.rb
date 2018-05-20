class AddUserRefToIndexArticleHistory < ActiveRecord::Migration[5.1]
  def change
    change_table :index_history_articles do |t|
      t.references :user, index: false
    end
  end
end
