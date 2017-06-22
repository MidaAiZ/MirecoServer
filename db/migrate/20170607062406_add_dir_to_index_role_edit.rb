class AddDirToIndexRoleEdit < ActiveRecord::Migration
  def change
    change_table :index_role_edits do |t|
      t.references :dir, polymorphic: true
    end
    add_index :index_role_edits, [:dir_id, :dir_type], name: :index_role_edit_on_dir_id_type
  end
end
