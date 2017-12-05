class AddIndexFileSeedToFiles < ActiveRecord::Migration[4.2]
  def change
    change_table :index_articles do |t|
      t.references :index_file_seed
    end
    change_table :index_corpus do |t|
      t.references :index_file_seed
    end
    change_table :index_folders do |t|
      t.references :index_file_seed
    end
  end
end
