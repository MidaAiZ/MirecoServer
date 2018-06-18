class Index::LoginRecord < ApplicationRecord
  belongs_to :user,
              class_name: 'Index::User',
              foreign_key: :user_id

  def self.add user, ip
    record = self.new
    record.ip = ip
    record.user = user
    record.time = Time.now
    record.save
    record
  end

  def self.day_alive
    self.select(:user_id).where(time: Time.now.midnight..Time.now).distinct
  end

  def self.alive time_begin, time_end
    self.select(:user_id).where(time: time_begin..time_end).distinct
  end
end
