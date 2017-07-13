if @code
  json.code @code
else
  json.counts @counts
  json.files do
    json.array! @edit_roles do |role|
      seed = role.file_seed
      file = seed.root_file
      json.role role.name
      json.editors_count seed.editors_count
      json.file_type file.file_type
      json.file do
        case file.file_type
        when :folders
          json.extract! file, :id, :name, :is_marked, :created_at, :updated_at
        else
          json.extract! file, :id, :name, :tag, :is_shown, :is_marked, :created_at, :updated_at
        end
      end
    end
  end
end
