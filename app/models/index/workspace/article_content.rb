class Index::Workspace::ArticleContent < ApplicationRecord
	belongs_to :article,
				class_name: 'Index::Workspace::Article',
				foreign_key: :article_id

	validates :text, length: { maximum: 100_000_00 }, allow_blank: true
end
