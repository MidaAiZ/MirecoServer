class CreateIndexArtCmtLike < ActiveRecord::Migration[5.1]
  def change
    create_table :index_art_cmt_likes do |t|
      t.references :user, index: false
      t.references :cmt, index: false
      t.datetime :created_at
    end
    add_index :index_art_cmt_likes, :user_id, name: "idx_art_likes_on_user_id"
    add_index :index_art_cmt_likes, :cmt_id, name: "idx_art_likes_on_cmt_id"
  end
end
