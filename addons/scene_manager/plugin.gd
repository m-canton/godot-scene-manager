@tool
extends EditorPlugin

var _export_plugin: EditorExportPlugin

func _enter_tree() -> void:
	add_autoload_singleton("SceneManager", "res://addons/scene_manager/autoload/scene_manager.tscn")
	
	# Removes files from test and editor folders.
	_export_plugin = preload("res://addons/scene_manager/editor/export.gd").new()
	add_export_plugin(_export_plugin)
	
	_init_settings()


func _exit_tree() -> void:
	remove_autoload_singleton("SceneManager")
	
	remove_export_plugin(_export_plugin)
	_export_plugin = null


func _init_settings() -> void:
	# Transition canvas layer index. Change this value in settings if you use
	# other canvas layers.
	if not ProjectSettings.has_setting(SceneTransition.SETTING_NAME_LAYER):
		ProjectSettings.set_setting(SceneTransition.SETTING_NAME_LAYER, SceneTransition.DEFAULT_LAYER)
	ProjectSettings.set_initial_value(SceneTransition.SETTING_NAME_LAYER, SceneTransition.DEFAULT_LAYER)
	ProjectSettings.set_as_basic(SceneTransition.SETTING_NAME_LAYER, true)
	ProjectSettings.add_property_info({
		"name": SceneTransition.SETTING_NAME_LAYER,
		"type": TYPE_INT,
	})
	
	if not ProjectSettings.has_setting(LoadingScreen.SETTING_NAME_PRINT_LOADING_TIMES):
		ProjectSettings.set_setting(LoadingScreen.SETTING_NAME_PRINT_LOADING_TIMES, false)
	ProjectSettings.set_initial_value(LoadingScreen.SETTING_NAME_PRINT_LOADING_TIMES, false)
	ProjectSettings.set_as_basic(LoadingScreen.SETTING_NAME_PRINT_LOADING_TIMES, true)
	ProjectSettings.add_property_info({
		"name": LoadingScreen.SETTING_NAME_PRINT_LOADING_TIMES,
		"type": TYPE_BOOL,
	})
	
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
