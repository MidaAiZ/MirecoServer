class CreateIndexPublishedArticle < ActiveRecord::Migration[5.1]
  def change
    create_table :index_published_articles do |t|
      t.string :name
      t.string :tag
      t.string :cover
      t.integer :state, default: 1
      t.references :user, index: false
      t.references :corpus, index: false
      t.references :origin, index: false
      t.references :content, index: false
      t.integer :read_times_cache, default: 0
      t.integer :thumbs_count_cache, default: 0
      t.integer :comments_count_cache, default: 0

      t.timestamps null: false
    end
    add_index :index_published_articles, :user_id, name: :index_publish_article_on_uid
    add_index :index_published_articles, :corpus_id, name: :index_publish_article_on_copus_id
    add_index :index_published_articles, :origin_id, name: :index_publish_article_on_origin_id
  end
end
