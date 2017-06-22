class Index::Workspace::HistoryArticle < ActiveRecord::Base
  belongs_to :origin,
              class_name: 'Index::Workspace::Article',
              foreign_key: 'article_id'

  # 实现文章搜索功能
  default_scope { order('index_history_articles.id DESC') }
  scope :his_art_include, ->(title, tag) { where('index_history_articles.title LIKE ? OR index_history_articles.tag LIKE ?', "%#{name}%", "%#{tag}%") }

  def self.filter(condition = {})
    name = condition[:name]
    tag = condition[:tag]
    Index::Workspace::Article.his_art_include(name, tag)
  end
end
