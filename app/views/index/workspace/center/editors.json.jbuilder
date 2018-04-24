json.editors do
	json.array! @edit_roles do |role|
		json.role role.name
		json.editor do
			editor = role.editor
			json.extract! editor, :id, :number
			json.avatar editor.avatar.url
		end
	end
end
json.editors_count  @edit_roles.size
