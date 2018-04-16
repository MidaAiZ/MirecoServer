class RemoveFilesCountOfIndexFileSeed < ActiveRecord::Migration
  def change
    remove_column :index_file_seeds, :files_count
  end
end
