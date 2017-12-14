class CreateIndexEditCommentReplies < ActiveRecord::Migration[5.1]
  def change
    create_table :index_edit_comment_replies do |t|
      t.references :edit_comment, index: false
      t.references :user, index: false
      t.string :content
    end
  end
end
