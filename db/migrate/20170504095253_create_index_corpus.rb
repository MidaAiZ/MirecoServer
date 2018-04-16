class CreateIndexCorpus < ActiveRecord::Migration
  def change
    create_table :index_corpus do |t|
      t.string :name
      t.string :tag
      t.boolean :is_inner
     
      t.timestamps null: false
    end
  end
end
