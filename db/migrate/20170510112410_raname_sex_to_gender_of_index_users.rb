class RanameSexToGenderOfIndexUsers < ActiveRecord::Migration[4.2]
  def change
    rename_column :index_users, :sex, :gender
  end
end
