class Index::ArtCmtLike < ApplicationRecord
  belongs_to :comment,
          class_name: 'Index::ArtComment',
          foreign_key: :cmt_id

  belongs_to :user,
             class_name: 'Index::User',
             foreign_key: :user_id

  default_scope { order(id: :DESC) }

  def create u, cmt
    return false if self.id
    self.user = u
    self.comment = cmt
    save
  end

  def cancel
    destroy
  end
end
