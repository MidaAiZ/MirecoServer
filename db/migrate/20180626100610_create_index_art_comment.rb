class CreateIndexArtComment < ActiveRecord::Migration[5.1]
  def change
    create_table :index_art_comments do |t|
      t.references :user, index: false
      t.references :article, index: false
      t.string :content
      t.integer :likes_count_cache, default: 0
      t.integer :replies_count_cache, default: 0
      t.datetime :created_at
    end
    add_index :index_art_comments, :user_id, name: :idx_art_cmts_on_user_id
    add_index :index_art_comments, :article_id, name: :idx_art_cmts_on_art_id
  end
end
