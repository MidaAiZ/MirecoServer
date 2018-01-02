if @code
  json.code @code
else
  json.files do
    json.array! @edit_roles do |role|
      json.role role.name
      seed = role.file_seed
      file = seed.root_file
      json.file_type file.file_type
      json.editors_count seed.editors_count
      json.file do
        case file.file_type
        when :folders
          json.extract! file, :id, :name, :created_at, :updated_at
        else
          json.extract! file, :id, :name, :tag, :created_at, :updated_at, :cover
        end
        json.is_marked file.is_marked @user.id
      end
    end
  end
end
