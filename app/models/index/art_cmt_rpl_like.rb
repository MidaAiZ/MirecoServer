class Index::ArtCmtRplLike < ApplicationRecord
  belongs_to :reply,
          class_name: 'Index::ArtCmtReply',
          foreign_key: :reply_id

  belongs_to :user,
             class_name: 'Index::User',
             foreign_key: :user_id

  default_scope { order(id: :DESC) }

  def create u, reply
    return false if self.id

    self.user = u
    self.reply = reply
    save
  end

  def cancel
    destroy
  end
end
