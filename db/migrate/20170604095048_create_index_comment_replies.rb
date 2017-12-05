class CreateIndexCommentReplies < ActiveRecord::Migration[4.2]
  def change
    create_table :index_comment_replies do |t|
      t.integer :comment_id
      t.integer :user_id
      t.string  :content

      t.timestamps null: false
    end
    add_index :index_comment_replies, :comment_id, name: 'index_comment_reply_on_com_id'
    add_index :index_comment_replies, :user_id, name: 'index_comment_reply_on_user_id'
  end
end
