class Index::Workspace::MarkRecord < ApplicationRecord
    # belongs_to :file_seed,
    #             class_name: 'Index::Workspace::FileSeed',
    #             foreign_key: :file_seed_id

    belongs_to :file,
               polymorphic: true,
               optional: true

    belongs_to :editor,
                class_name: 'Index::User',
                foreign_key: :user_id

    default_scope { order(id: :DESC) }

    def self._create editor, file
        _self = self.find_or_initialize_by(user_id: editor.id, file_id: file.id, file_type: file.class.name)
        return true if _self.id
        _self.save!
        ids = file.marked_u_ids || []
        ids << editor.id
        ids.uniq!
        file.update! marked_u_ids: ids
    end

    def _destroy(editor, file)
        self.destroy!
        ids = file.marked_u_ids || []
        ids.delete editor.id
        file.update! marked_u_ids: ids
    end
end
