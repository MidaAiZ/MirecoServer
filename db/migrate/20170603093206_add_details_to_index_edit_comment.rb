class AddDetailsToIndexEditComment < ActiveRecord::Migration
  def change
    change_table :index_edit_comments do |t|
      t.integer :user_id
      t.string :hash_key
    end
    add_index :index_edit_comments, :user_id, name: 'index_edit_comment_on_user_id'
    add_index :index_edit_comments, :hash_key, name: 'index_edit_comment_on_hash_key'
  end
end
