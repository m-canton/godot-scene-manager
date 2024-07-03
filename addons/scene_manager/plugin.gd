@tool
extends EditorPlugin

var _export_plugin: EditorExportPlugin

func _enter_tree() -> void:
	add_autoload_singleton("SceneManager", "res://addons/scene_manager/autoload/scene_manager.gd")
	
	# Removes files from test and editor folders.
	_export_plugin = preload("res://addons/scene_manager/editor/export.gd").new()
	add_export_plugin(_export_plugin)
	
	#region Settings
	if not ProjectSettings.has_setting(LoadingScreen.SETTING_NAME):
		ProjectSettings.set_setting(LoadingScreen.SETTING_NAME, LoadingScreen.SETTING_DEFAULT_VALUE)
	ProjectSettings.set_initial_value(LoadingScreen.SETTING_NAME, LoadingScreen.SETTING_DEFAULT_VALUE)
	ProjectSettings.set_as_basic(LoadingScreen.SETTING_NAME, true)
	ProjectSettings.add_property_info({
		name = LoadingScreen.SETTING_NAME,
		type = TYPE_STRING,
		hint = PROPERTY_HINT_FILE,
		hint_string = "*.scn,*.tscn",
	})
	#endregion


func _exit_tree() -> void:
	remove_autoload_singleton("SceneManager")
	
	remove_export_plugin(_export_plugin)
	_export_plugin = null
