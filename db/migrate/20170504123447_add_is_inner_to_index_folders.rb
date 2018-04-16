class AddIsInnerToIndexFolders < ActiveRecord::Migration
  def change
    change_table :index_folders do |t|
      t.boolean :is_inner, default: false
    end
  end
end
