class Index::ArticleReadRecord < ApplicationRecord
  belongs_to :article,
          class_name: 'Index::PublishedArticle',
          foreign_key: :article_id

  belongs_to :user,
             class_name: 'Index::User',
             foreign_key: :user_id,
             optional: true


  validates :ip, presence: true, allow_blank: false

  default_scope { order(id: :DESC) }

  def create ip, u
    return false if self.id
    
    self.ip = ip
    self.user = u
    self.read_time = Time.now

    save
  end
end
