class Manage::Admin < ApplicationRecord
  # 使用插件建立用户密码验证体系
  has_secure_password

  mount_uploader :avatar, AdminAvatarUploader # 头像上传

  has_many :login_records,
           class_name: 'Manage::Admin',
           foreign_key: :admin_id

  has_many :operation,
           class_name: 'Manage::OperationRecord',
           foreign_key: :admin_id

  validates :number, presence: true, uniqueness: { message: '该帐号已被注册' },
                     length: { minimum: 2, maximum: 16 },
                     format: { with: Validate::VALID_ACCOUNT_REGEX },
                     allow_blank: false
  validates :password, presence: true, length: { minimum: 6, maximum: 20 },
                       format: { with: Validate::VALID_PASSWORD_REGEX },
                       allow_blank: false, on: [:create]
  validates :password_digest, presence: true, allow_blank: false, on: [:update]
  validates :mail, presence: false, uniqueness: { message: '该邮箱已被注册' },
                    length: { maximum: 255 },
                    format: { with: Validate::VALID_EMAIL_REGEX },
                    allow_blank: true
  validates :tel, presence: true, uniqueness: { message: '该手机号已被注册' },
                    format: { with: Validate::VALID_PHONE_REGEX },
                    allow_blank: false

  def self.fetch_login(id, request)
    Cache.new.fetch(cache_key(id), 2 * 60 * 10) do
      admin = find_by_id(id)
      # 记录登录信息
      Manage::LoginRecord.add(admin, request.remote_ip) if admin
      admin
    end
  end
end
