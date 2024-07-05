@tool
extends EditorPlugin

var _export_plugin: EditorExportPlugin

func _enter_tree() -> void:
	add_autoload_singleton("SceneManager", "res://addons/scene_manager/autoload/scene_manager.gd")
	
	# Removes files from test and editor folders.
	_export_plugin = preload("res://addons/scene_manager/editor/export.gd").new()
	add_export_plugin(_export_plugin)
	
	#region ProjectSettings
	if not ProjectSettings.has_setting(LoadingScreen.SETTING_NAME_DEFAULT_PATH):
		ProjectSettings.set_setting(LoadingScreen.SETTING_NAME_DEFAULT_PATH, LoadingScreen.DEFAULT_PATH)
	ProjectSettings.set_initial_value(LoadingScreen.SETTING_NAME_DEFAULT_PATH, LoadingScreen.DEFAULT_PATH)
	ProjectSettings.set_as_basic(LoadingScreen.SETTING_NAME_DEFAULT_PATH, true)
	ProjectSettings.add_property_info({
		"name": LoadingScreen.SETTING_NAME_DEFAULT_PATH,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.scn,*.tscn"
	})
	#endregion


func _exit_tree() -> void:
	remove_autoload_singleton("SceneManager")
	
	remove_export_plugin(_export_plugin)
	_export_plugin = null
