class AddForeignkeyToIndexFolders < ActiveRecord::Migration[4.2]
  def change
    change_table :index_folders do |t|
      t.references :index_folder, foreign_keys: true, index: true
    end
  end
end
