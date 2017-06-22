class RenameReplysOfIndexEditComment < ActiveRecord::Migration
  def change
    rename_column :index_edit_comments, :replys, :replies
  end
end
