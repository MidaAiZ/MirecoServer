class AddTmpCountsToIndexComments < ActiveRecord::Migration[4.2]
  def change
    add_column :index_comments, :info, :jsonb
    add_column :index_comment_replies, :info, :jsonb

    add_index :index_comments, :info, name: :index_comments_on_info, using: :gin
    add_index :index_comment_replies, :info, name: :index_comment_replies_on_info, using: :gin
  end
end
