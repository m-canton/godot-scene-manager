@tool
extends EditorPlugin

var _export_plugin: EditorExportPlugin

func _enter_tree() -> void:
	add_autoload_singleton("SceneManager", "res://addons/scene_manager/autoload/scene_manager.tscn")
	
	# Removes files from test and editor folders.
	_export_plugin = preload("res://addons/scene_manager/editor/export.gd").new()
	add_export_plugin(_export_plugin)
	
	# Settings
	_set_setting(SceneTransition.SETTING_NAME_LAYER, SceneTransition.DEFAULT_LAYER)
	_set_setting(LoadingScreen.SETTING_NAME_PRINT_LOADING_TIMES, false)
	_set_setting(LoadingScreen.SETTING_NAME_DEFAULT_PATH, LoadingScreen.DEFAULT_PATH, true, {
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.scn,*.tscn",
	})

func _exit_tree() -> void:
	remove_autoload_singleton("SceneManager")
	
	remove_export_plugin(_export_plugin)
	_export_plugin = null

func _set_setting(setting_name: String, default_value, basic := true, property_info := {}) -> void:
	if not ProjectSettings.has_setting(setting_name):
		ProjectSettings.set_setting(setting_name, default_value)
	ProjectSettings.set_initial_value(setting_name, default_value)
	ProjectSettings.set_as_basic(setting_name, basic)
	if not property_info.is_empty():
		property_info["name"] = setting_name
		property_info["type"] = property_info.get("type", typeof(default_value))
		ProjectSettings.add_property_info(property_info)
