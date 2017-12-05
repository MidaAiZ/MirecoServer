class CreateIndexFileSeed < ActiveRecord::Migration[4.2]
  def change
    create_table :index_file_seeds do |t|
      t.integer :file_count
      t.integer :editor_count
    end
    change_table :index_role_edits do |t|
      t.references :index_file_seed
      t.remove :resource_id
      t.remove :resource_type
    end
  end
end
