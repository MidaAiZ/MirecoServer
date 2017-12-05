class AddDefaultsToIndexfolders < ActiveRecord::Migration[4.2]
  def change
    change_column_default :index_folders, :is_deleted, false
  end
end
