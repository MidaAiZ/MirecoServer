class AddThumbsCountToIndexThumbUp < ActiveRecord::Migration[4.2]
  def change
    add_column :index_thumb_ups, :thumbs_count, :integer, default: 0
  end
end
