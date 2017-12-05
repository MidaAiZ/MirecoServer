class AddIntroToIndexUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :index_users, :intro, :string
  end
end
