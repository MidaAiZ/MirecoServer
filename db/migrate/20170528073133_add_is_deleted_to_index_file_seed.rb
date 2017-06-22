class AddIsDeletedToIndexFileSeed < ActiveRecord::Migration
  def change
    change_table :index_file_seeds do |t|
        t.boolean :is_deleted, default: false, index: true
    end
  end
end
