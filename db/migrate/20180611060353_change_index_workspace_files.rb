class ChangeIndexWorkspaceFiles < ActiveRecord::Migration[5.1]
  def change
    change_table :index_articles do |t|
      t.remove :cover
      t.remove :is_shown
      t.remove_index :info
      t.remove_index :name
      t.remove_index :tag
      t.references :release, index: false
    end
    change_table :index_corpus do |t|
      t.remove :cover
      t.remove :is_shown
      t.remove_index :info
      t.remove_index :name
      t.remove_index :tag
      t.references :release, index: false
    end
    change_table :index_folders do |t|
      t.remove :tag
      t.remove :is_shown
      t.remove_index :info
      t.remove_index :name
    end
  end
end
