class AddForeignkeyToIndexCorpus < ActiveRecord::Migration[4.2]
  def change
    change_table :index_corpus do |t|
      t.references :index_user, foreign_keys: true, index: true
      t.references :index_folder, foreign_keys: true, index: true
    end
  end
end
