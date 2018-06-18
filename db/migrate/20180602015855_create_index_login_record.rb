class CreateIndexLoginRecord < ActiveRecord::Migration[5.1]
  def change
    create_table :index_login_records do |t|
      t.string :ip
      t.timestamp :time
      t.references :user
    end
  end
end
