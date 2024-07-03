extends EditorExportPlugin


var regex := RegEx.new()

func _export_begin(features, is_debug, path, flags):
	var error := regex.compile("^res://addons/scene_manager/(?:test|editor)")
	if error:
		push_error(error_string(error))

func _export_file(path, type, features):
	var result := regex.search(path)
	if result:
		push_warning("File removed: ", path, result.names)
		skip()
	else:
		print(path)

func _get_name() -> String:
	return "SceneManager"
