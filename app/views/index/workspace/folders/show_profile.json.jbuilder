json.files do
    json.array! @files do |file|
      seed = file.file_seed
      json.file_type file.file_type
      json.editors_count seed.editors_count
      json.file do
        case file.file_type
        when :folders
          json.extract! file, :id, :name, :created_at, :updated_at, :file_seed_id
        else
          json.extract! file, :id, :name, :tag, :created_at, :updated_at, :file_seed_id
        end
        json.is_marked file.is_marked @user.id
      end
    end
end
