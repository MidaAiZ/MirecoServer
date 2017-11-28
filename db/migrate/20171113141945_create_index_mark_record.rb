class CreateIndexMarkRecord < ActiveRecord::Migration[5.1]
  def change
    create_table :index_mark_records do |t|
      t.references :user, index: false
      t.references :file_seed, index: false
      t.references :file, :polymorphic => true, index: false
    end
    add_index :index_mark_records, :user_id, name: :index_mark_records_on_user_id
    add_index :index_mark_records, :file_seed_id, name: :index_mark_records_on_file_seed_id
    add_index :index_mark_records, [:file_id, :file_type], name: :index_mark_records_on_file_id_type
  end
end
