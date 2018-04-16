class Index::UserImage < ApplicationRecord
  mount_uploader :file,  UserImageUploader # 封面上传

  belongs_to :user,
             class_name: 'Index::User',
             foreign_key: :user_id

  validates :file, presence: true, allow_blank: false
end
