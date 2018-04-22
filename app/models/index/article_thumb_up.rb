class Index::ArticleThumbUp < ApplicationRecord
  belongs_to :article,
          class_name: 'Index::PublishedArticle',
          foreign_key: :article_id

  belongs_to :user,
             class_name: 'Index::User',
             foreign_key: :user_id

  default_scope { order(id: :DESC) }

  def create u
    return false if self.id
    
    self.user = u
    save
  end

  def cancel
    destroy
  end
end
