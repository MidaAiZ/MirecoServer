class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.cache_key id
    $redis.select 2
    "#{id}_#{self.name}"
  end

  def self.fetch id
    Cache.new.fetch(cache_key(id)) {
      self.unscope(:where).find_by_id(id)
    }
  end

  def cache_key
    self.class.cache_key(self.id)
  end

  def update_cache
    Cache.new[self.cache_key] = self
  end

  def clear_cache
    Cache.new[self.cache_key] = nil
  end
end
