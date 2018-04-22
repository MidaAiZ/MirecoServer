class CreateIndexArticleReadRecord < ActiveRecord::Migration[5.1]
  def change
    create_table :index_article_read_records do |t|
      t.references :article, index: false
      t.references :user, index: false
      t.timestamp :read_time
      t.string :ip
    end
    add_index :index_article_read_records, :user_id, name: :index_art_read_records_on_uid
    add_index :index_article_read_records, :article_id, name: :index_art_read_records_on_art_id
  end
end
