class AddMarkedUIdsToIndexFiles < ActiveRecord::Migration[5.1]
  def change
    change_table :index_articles do |t|
        t.remove :is_marked
        t.integer :marked_u_ids, array: true
    end
    change_table :index_corpus do |t|
        t.remove :is_marked
        t.integer :marked_u_ids, array: true
    end
    change_table :index_folders do |t|
        t.remove :is_marked
        t.integer :marked_u_ids, array: true
    end
  end
end
