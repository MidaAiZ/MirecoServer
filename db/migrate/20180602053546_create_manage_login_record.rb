class CreateManageLoginRecord < ActiveRecord::Migration[5.1]
  def change
    create_table :manage_login_records do |t|
      t.string :ip
      t.timestamp :time
      t.references :admin, index: false
    end
    add_index :manage_login_records, :admin_id, name: :idx_mng_login_records_on_admin_id
  end
end
