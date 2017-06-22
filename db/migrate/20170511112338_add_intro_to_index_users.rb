class AddIntroToIndexUsers < ActiveRecord::Migration
  def change
    add_column :index_users, :intro, :string
  end
end
