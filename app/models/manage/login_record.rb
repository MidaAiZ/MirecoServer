class Manage::LoginRecord < ApplicationRecord
  belongs_to :admin,
              class_name: 'Manage::Admin',
              foreign_key: :admin_id

  def self.add admin, ip
    record = self.new
    record.ip = ip
    record.admin = admin
    record.time = Time.now
    record.save
    record
  end
end
