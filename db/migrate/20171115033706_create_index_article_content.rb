class CreateIndexArticleContent < ActiveRecord::Migration[5.1]
  def change
    create_table :index_article_contents do |t|
        t.references :article, index: false
        t.references :last_update_user, index: false
        t.timestamp :last_updated_at
        t.string :text, default: ''
    end
    change_table :index_articles do |t|
        t.remove :content
    end
    add_index :index_article_contents, :article_id, name: :index_article_contents_on_art_id
  end
end
