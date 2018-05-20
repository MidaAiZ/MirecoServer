class Index::Workspace::ArticleContent < ApplicationRecord

  after_destroy :clear_cache

	belongs_to :article, -> { with_del },
				class_name: 'Index::Workspace::Article',
				foreign_key: :article_id

	validates :text, length: { maximum: 100_000_00 }, allow_blank: true

	def update_text text
		self.last_updated_at = Time.now
		# 不保存， 将更新交给事件队列
		update_cache text
	end

  @override
	def self.fetch id
		content = $redis.GET(cache_key(id))
		if content
			content = Marshal.load(content)
			content.text = $redis.GET(text_cache_key(content)) || content.text
		else
			content = self.find_by_id id
			if content
				text = $redis.GET(text_cache_key(content)) || content.text
				content.text = nil
				$redis.SETEX content.cache_key, 1 * 30 * 60, Marshal.dump(content)
				$redis.SETEX text_cache_key(content), 1 * 30 * 60, text
				content.text = text
			end
		end
		content
  end

  @override
	def update_cache text
		if (!self.in_update_queue?)
			$redis.PERSIST self.cache_key
			$redis.PERSIST self.text_cache_key
			puts ArtContentWorker.perform_at(2.hours.from_now, self.id, self.cache_key)
		end
		$redis.SET(self.text_cache_key, text)
	end

	@override
	def clear_cache
		$redis.DEL self.cache_key, self.text_cache_key
	end

	def text_cache_key
		 self.class.text_cache_key self
	end

	def self.text_cache_key content
		Index::Workspace::Article.text_cache_key(content.article_id)
	end

	def in_update_queue?
		$redis.TTL(self.cache_key) == -1
	end

end
