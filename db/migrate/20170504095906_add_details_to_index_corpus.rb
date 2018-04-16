class AddDetailsToIndexCorpus < ActiveRecord::Migration
  def change
    change_table :index_corpus do |t|
      t.boolean :is_shown
      t.boolean :is_marked
      t.boolean :is_deleted, default: false
      t.change_default :is_inner, false
    end
  end
end
