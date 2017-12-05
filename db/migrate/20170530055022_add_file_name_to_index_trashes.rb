class AddFileNameToIndexTrashes < ActiveRecord::Migration[4.2]
  def change
    add_column :index_trashes, :file_name, :string
  end
end
