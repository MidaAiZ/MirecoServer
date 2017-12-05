class AddFileToIndexTrashes < ActiveRecord::Migration[4.2]
  def change
    change_table :index_trashes do |t|
      t.references :file, :polymorphic => true
    end
    add_index :index_trashes, [:file_id, :file_type], name: 'index_trashes_on_file_type_id'
  end
end
