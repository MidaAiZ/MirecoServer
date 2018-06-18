module Manage
  def self.table_name_prefix
    'manage_'
  end
  module Role
    def self.table_name_prefix
      'manage_role_'
    end
  end
end
