class CreateIndexComments < ActiveRecord::Migration[4.2]
  def change
    create_table :index_comments do |t|
      t.string :content
      t.integer :user_id
      t.references :resource, :polymorphic => true

      t.timestamps null: false
    end
    add_index(:index_comments, :user_id, name: 'index_comment_on_user_id')
    add_index(:index_comments, [:resource_type, :resource_id], name: 'index_comment_on_name_rsc')
  end
end
