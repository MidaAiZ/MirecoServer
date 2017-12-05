class ChangeIndexEditRoles < ActiveRecord::Migration[4.2]
  def change
    change_table :index_role_edits do |t|
      t.remove :is_root
      t.rename :editor_name, :nickname
    end
  end
end
