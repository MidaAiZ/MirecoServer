class CreateIndexUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :index_users do |t|
      t.string :number
      t.string :password_digest
      t.string :name
      t.string :phone
      t.string :email
      t.string :sex
      t.date :birthday
      t.string :address
      t.string :avatar
      t.boolean :forbidden

      t.timestamps null: false
    end
  end
end
