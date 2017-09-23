if @code
  json.code @code
else
  json.counts @counts
  json.files do
    json.array! @marked_articles do |file|
      json.file_type file.file_type
      json.file do
        json.extract! file, :id, :name, :tag, :is_shown, :is_marked, :created_at, :updated_at
      end
    end
	json.array! @marked_corpuses do |file|
	  json.file_type file.file_type
	  json.file do
		json.extract! file, :id, :name, :tag, :is_shown, :is_marked, :created_at, :updated_at
	  end
	end
	json.array! @marked_folders do |file|
      json.file_type file.file_type
      json.file do
        json.extract! file, :id, :name, :is_marked, :created_at, :updated_at
      end
    end
  end
end
