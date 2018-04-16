class CreateIndexUserImages < ActiveRecord::Migration[5.1]
  def change
    create_table :index_user_images do |t|
      t.string :file
      t.references :user, index: false
    end
  end
end
