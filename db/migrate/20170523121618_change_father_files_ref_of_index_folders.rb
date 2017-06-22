class ChangeFatherFilesRefOfIndexFolders < ActiveRecord::Migration
  def change
    change_table :index_folders do |t|
      t.remove :index_folder_id
      t.references :dir, :polymorphic => true
    end
    add_index "index_folders", ["dir_type", "dir_id"], name: "index_folder_on_dir_type_id"
  end
end
