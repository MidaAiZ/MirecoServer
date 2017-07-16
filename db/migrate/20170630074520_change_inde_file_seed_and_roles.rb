class ChangeIndeFileSeedAndRoles < ActiveRecord::Migration
  def change
    add_column :index_role_edits, :is_deleted, :boolean, default: false
    remove_column :index_file_seeds, :is_deleted
  end
end
