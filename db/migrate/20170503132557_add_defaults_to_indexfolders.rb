class AddDefaultsToIndexfolders < ActiveRecord::Migration
  def change
    change_column_default :index_folders, :is_deleted, false
  end
end
