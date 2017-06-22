class RanameSexToGenderOfIndexUsers < ActiveRecord::Migration
  def change
    rename_column :index_users, :sex, :gender
  end
end
