class AddFileNameToIndexTrashes < ActiveRecord::Migration
  def change
    add_column :index_trashes, :file_name, :string
  end
end
