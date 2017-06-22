class MyWorker
  include Sidekiq::Worker

  def perform
     # do somethings
	 user = Index::User.last
     Emailer.info_email(user, "Mireco异步邮件测试", "你好啊, 吴先生").deliver_now
     puts 'Doing hard work'
  end
end
