class Manage::Operation < ApplicationRecord
  belongs_to :admin,
              class_name: 'Manage::Admin',
              foreign_key: :admin_id

  belongs_to :resource, polymorphic: true
end
