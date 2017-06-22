class MySchedule
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence do
    minutely(1)
    # secondly(1)
  end

  def perform
    puts "sidetip 测试"
    puts Index::User.first
  end
end
