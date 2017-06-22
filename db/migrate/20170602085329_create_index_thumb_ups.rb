class CreateIndexThumbUps < ActiveRecord::Migration
  def change
    create_table :index_thumb_ups do |t|
      t.references :resource,  :polymorphic => true
      t.jsonb :thumbs, default: '{}'
      t.timestamps null: false
    end
    add_index :index_thumb_ups, [:resource_id, :resource_type], name: :index_thumb_up_on_resource
    add_index :index_thumb_ups, :thumbs, name: :index_thumb_up_on_thumbs, using: :gin
  end
end
