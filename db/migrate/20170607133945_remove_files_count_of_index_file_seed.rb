class RemoveFilesCountOfIndexFileSeed < ActiveRecord::Migration[4.2]
  def change
    remove_column :index_file_seeds, :files_count
  end
end
