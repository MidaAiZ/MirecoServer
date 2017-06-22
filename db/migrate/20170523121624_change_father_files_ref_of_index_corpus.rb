class ChangeFatherFilesRefOfIndexCorpus < ActiveRecord::Migration
    def change
      change_table :index_corpus do |t|
        t.remove :index_folder_id
        t.references :dir, :polymorphic => true
      end
      add_index "index_corpus", ["dir_type", "dir_id"], name: "index_corpus_on_dir_type_id"
    end
end
