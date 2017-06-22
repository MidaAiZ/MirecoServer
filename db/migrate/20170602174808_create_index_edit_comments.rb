class CreateIndexEditComments < ActiveRecord::Migration
  def change
    create_table :index_edit_comments do |t|
      t.references :resource,  :polymorphic => true
      t.string :content
      t.jsonb :replys, default: '{}'

      t.timestamps null: false
    end
    add_index :index_edit_comments, [:resource_id, :resource_type], name: :index_edit_comments_on_resource
    add_index :index_edit_comments, :replys, name: :index_edit_comments_on_replys, using: :gin
  end
end
