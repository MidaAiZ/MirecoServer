class AddFilesRefToIndexFileSeeds < ActiveRecord::Migration[4.2]
  def change
    change_table :index_file_seeds do |t|
      t.references :root_file, :polymorphic => true
    end
    add_index "index_file_seeds", ["root_file_type", "root_file_id"], name: "index_file_seed_on_root_file_type_id"
  end
end
