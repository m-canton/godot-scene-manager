extends EditorExportPlugin


var _regex := RegEx.new()
var _can_remove_test := false

func _export_begin(features, is_debug, path, flags):
	var error := _regex.compile("^res://addons/scene_manager/(?:test|editor)")
	if error:
		push_error(error_string(error))
	elif not _regex.search(ProjectSettings.get_setting("application/run/main_scene")):
		_can_remove_test = true

func _export_file(path, type, features):
	if _can_remove_test:
		var result := _regex.search(path)
		if result:
			print("SceneManager: File skipped: ", path, result.names)
			skip()

func _get_name() -> String:
	return "SceneManager"
