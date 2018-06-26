class Index::ArticleLike < ApplicationRecord
  belongs_to :user,
  class_name: 'Index::User',
  foreign_key: :user_id

  belongs_to :article, -> { all_state },
          class_name: 'Index::PublishedArticle',
          foreign_key: :article_id

  default_scope { order(id: :DESC) }

  def create u, art
    return false if self.id
    return false if !art.released?

    self.article = art
    self.user = u
    save
  end

  def cancel
    destroy
  end
end
