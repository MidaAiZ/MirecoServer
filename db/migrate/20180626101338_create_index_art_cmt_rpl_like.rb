class CreateIndexArtCmtRplLike < ActiveRecord::Migration[5.1]
  def change
    create_table :index_art_cmt_rpl_likes do |t|
      t.references :user, index: false
      t.references :reply, index: false
      t.datetime :created_at
    end
    add_index :index_art_cmt_rpl_likes, :user_id, name: "idx_art_rpl_likes_on_user_id"
    add_index :index_art_cmt_rpl_likes, :reply_id, name: "idx_art_rpl_likes_on_rpl_id"
  end
end
