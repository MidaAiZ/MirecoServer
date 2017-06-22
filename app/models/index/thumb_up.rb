class Index::ThumbUp < ActiveRecord::Base
  # belongs_to :resource, polymorphic: true
  #
  # validates :resource_type, inclusion: { in: ['Index::Workspace::Article', 'Index::Workspace::Corpus', 'Index::Comment', 'Index::CommentReply'] }
  # validates :resource_id, presence: true

  #-------------------------- 添加赞 ------------------------#
  def self.add(resource, user)
    $redis.HSETNX(prefix(resource), user.id, Time.now.strftime('%Y-%m-%d %H:%M:%S')) == 1 ? true : false
  end

  #-------------------------- 取消赞 ------------------------#
  def self.cancel(resource, user)
    $redis.HDEL(prefix(resource), user.id) == 1 ? true : false
  end

  #-------------------------- 获取赞 ------------------------#
  def self.get(resource)
    $redis.HGETALL prefix(resource)
  end

  #-------------------------- 判断赞 ------------------------#
  def self.has?(resource, user)
    $redis.HEXISTS(prefix(resource), user.id) == 1 ? true : false
  end

  #-------------------------- 点赞数 ------------------------#
  def self.counts(resource)
    $redis.HLEN prefix(resource)
  end

  #-------------------------- 删除赞 ------------------------#
  def self.destroy(resource)
    $redis.DEL prefix(resource)
  end

  private

  def self.prefix(resource)
    return nil if resource.nil?
    $redis.select 2 # 设置database
    "index_thumbs_#{ resource.file_type }_#{ resource.id }"
  end

end
