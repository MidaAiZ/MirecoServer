class RenameReplysOfIndexEditComment < ActiveRecord::Migration[4.2]
  def change
    rename_column :index_edit_comments, :replys, :replies
  end
end
