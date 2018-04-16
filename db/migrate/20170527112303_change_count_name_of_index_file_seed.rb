class ChangeCountNameOfIndexFileSeed < ActiveRecord::Migration
  def change
    change_table :index_file_seeds do |t|
        t.remove :file_count
        t.remove :editor_count
        t.integer :files_count, default: 0
        t.integer :editors_count, default: 0
    end
  end
end
