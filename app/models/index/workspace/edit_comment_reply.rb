class Index::Workspace::EditCommentReply < ApplicationRecord
  belongs_to :user,
             class_name: 'Index::User',
             foreign_key: :user_id

  belongs_to :edit_comment,
             class_name: 'Index::Workspace::EditComment',
             foreign_key: :edit_comment_id


  # -------------------------赞--------------------------- #
  validates :user_id, presence: true
  validates :content, presence: true, length: { minimum: 1, maximum: 255 }

  default_scope { order(id: :DESC) }

end
