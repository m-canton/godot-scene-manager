@tool
extends EditorPlugin

const SceneManagerAutoload = preload("res://addons/scene_manager/autoload/scene_manager.gd")


func _enter_tree() -> void:
	add_autoload_singleton("SceneManager", "res://addons/scene_manager/autoload/scene_manager.gd")
	
	#region Settings
	if not ProjectSettings.has_setting(SceneManagerAutoload.LOADING_SCREEN_NAME_SETTING):
		ProjectSettings.set_setting(SceneManagerAutoload.LOADING_SCREEN_NAME_SETTING, SceneManagerAutoload.LOADING_SCREEN_PATH)
	ProjectSettings.set_initial_value(SceneManagerAutoload.LOADING_SCREEN_NAME_SETTING, SceneManagerAutoload.LOADING_SCREEN_PATH)
	ProjectSettings.set_as_basic(SceneManagerAutoload.LOADING_SCREEN_NAME_SETTING, true)
	ProjectSettings.add_property_info({
		name = SceneManagerAutoload.LOADING_SCREEN_NAME_SETTING,
		type = TYPE_STRING,
		hint = PROPERTY_HINT_FILE,
		hint_string = "*.scn,*.tscn",
	})
	#endregion


func _exit_tree() -> void:
	remove_autoload_singleton("SceneManager")
