class CreateIndexArtCmtReply < ActiveRecord::Migration[5.1]
  def change
    create_table :index_art_cmt_replies do |t|
      t.references :user, index: false
      t.references :comment, index: false
      t.string :content
      t.integer :likes_count_cache, default: 0
      t.integer :replies_count_cache, default: 0
      t.datetime :created_at
    end
    add_index :index_art_cmt_replies, :user_id, name: :idx_art_cmt_rpls_on_user_id
    add_index :index_art_cmt_replies, :comment_id, name: :idx_art_cmt_rpls_on_cmt_id
  end
end
