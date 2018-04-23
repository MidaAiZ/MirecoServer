class AddInfoToIndexTrash < ActiveRecord::Migration[5.1]
  def change
    change_table :index_trashes do |t|
      t.jsonb :info, default: {}
      t.remove :file_seed_id
    end
  end
end
