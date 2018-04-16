class CreateIndexTrashes < ActiveRecord::Migration
  def change
    create_table :index_trashes do |t|
      t.integer :file_seed_id, index: true
      t.integer :user_id, index: true
      t.integer :files_count

      t.timestamps null: false
    end
  end
end
