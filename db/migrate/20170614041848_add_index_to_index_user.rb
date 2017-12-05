class AddIndexToIndexUser < ActiveRecord::Migration[4.2]
  def change
    add_index :index_users, :number, name: :index_users_on_number
    add_index :index_users, :phone, name: :index_users_on_phone
    add_index :index_users, :email, name: :index_users_on_email
  end
end
