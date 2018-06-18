class CreateManageOperationRecord < ActiveRecord::Migration[5.1]
  def change
    create_table :manage_operation_records do |t|
      t.string :type
      t.string :message
      t.timestamp :time
      t.references :admin, index: false
      t.references :resources, index: false, :polymorphic => true
    end
    add_index :manage_operation_records, :admin_id, name: :idx_mng_opt_rcds_on_adm_id
  end
end
