class AddInfoToIndexRoleEdit < ActiveRecord::Migration[4.2]
  def change
    change_table :index_role_edits do |t|
        t.remove :is_marked
        t.remove :is_inner
        t.boolean :is_root, default: true
        t.jsonb :info
    end
    add_index :index_role_edits, :info, name: :index_roles_on_info, using: :gin
  end
end
