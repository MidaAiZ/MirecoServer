class AddIsInnerToIndexFolders < ActiveRecord::Migration[4.2]
  def change
    change_table :index_folders do |t|
      t.boolean :is_inner, default: false
    end
  end
end
