# encoding: utf-8
class EditorImageUploader < CarrierWave::Uploader::Base
  # Include RMagick or ImageScience support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/articles/images/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  process resize_to_fit: [600, 1000]
  # Create different versions of your uploaded files:
  version :thumb do
    process resize_to_fit: [180, 300]
  end
  #
  # version :content do
  #   process :resize_to_limit => [800, 800]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def filename
    if original_filename
      Digest::SHA2.hexdigest(original_filename)[0..12] + Time.now.to_i.to_s + ".#{original_filename.split('.')[-1]}"
    end
  end
end
