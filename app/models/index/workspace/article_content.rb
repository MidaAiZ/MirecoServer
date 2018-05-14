class Index::Workspace::ArticleContent < ApplicationRecord
	attr_accessor :in_update_queue # 更新时用来检查是否已经添加进更新队列

  after_destroy :clear_cache

	belongs_to :article, -> { with_del },
				class_name: 'Index::Workspace::Article',
				foreign_key: :article_id

	validates :text, length: { maximum: 100_000_00 }, allow_blank: true

	def update_text text
		self.text = text
		self.last_updated_at = Time.now
		# 不保存， 将更新交给事件队列
		update_cache
	end

  @override
	def self.fetch id
		content = $redis.GET(cache_key(id))
		if content
			content = Marshal.load content
		else
			content = self.find_by_id(id)
			$redis.SET(cache_key(id), Marshal.dump(content)) if content
		end
		return content
  end

  @override
	def update_cache
		if (!self.in_update_queue)
			join_update_queue
			puts ArtContentWorker.perform_at(2.hours.from_now, self.id, self.cache_key)
		end
		content = Marshal.dump(self)
		$redis.SET(self.cache_key, content)
	end

	@override
	def clear_cache
		$redis.DEL self.cache_key
	end

	private

	def join_update_queue
		self.in_update_queue = true
	end

	def leave_update_queue
		self.in_update_queue = false
	end
end
