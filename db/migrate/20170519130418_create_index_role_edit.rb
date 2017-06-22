class CreateIndexRoleEdit < ActiveRecord::Migration
  def change
    create_table :index_role_edits do |t|
        t.string :name
        t.string :editor_name
        t.boolean :is_marked, default: false
        t.references :index_user
        t.references :resource, :polymorphic => true

        t.timestamps
    end

    add_index(:index_role_edits, :name, name: 'index_role_edit_on_name')
    add_index(:index_role_edits, :index_user_id, name: 'index_role_edit_on_user_id')
    add_index(:index_role_edits, [:name, :resource_type, :resource_id], name: 'index_edit_role_on_name_rsc')
  end
end
