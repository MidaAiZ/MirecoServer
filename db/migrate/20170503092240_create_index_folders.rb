class CreateIndexFolder < ActiveRecord::Migration
  def change
    create_table :index_folders do |t|
      t.string :name
      t.string :tag
      t.boolean :is_shown
      t.boolean :is_marked
      t.boolean :is_deleted
      t.references :index_user

      t.timestamps null: false
    end
  end
end
