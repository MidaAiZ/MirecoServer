class CreateIndexArticleThumbUp < ActiveRecord::Migration[5.1]
  def change
    create_table :index_article_thumb_ups do |t|
      t.references :article, index: false
      t.references :user, index: false
      t.timestamp :thumb_time
    end
    add_index :index_article_thumb_ups, :user_id, name: :index_art_thumb_ups_on_uid
    add_index :index_article_thumb_ups, :article_id, name: :index_art_thumb_ups_on_art_id
  end
end
