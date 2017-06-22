module Index
  def self.table_name_prefix
    'index_'
  end
  module Role
    def self.table_name_prefix
      'index_role_'
    end
  end
end
