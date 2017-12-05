class CreateIndexCorpus < ActiveRecord::Migration[4.2]
  def change
    create_table :index_corpus do |t|
      t.string :name
      t.string :tag
      t.boolean :is_inner

      t.timestamps null: false
    end
  end
end
