@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("SceneManager", "res://addons/scene_manager/autoload/scene_manager.gd")
	
	#region Settings
	if not ProjectSettings.has_setting(LoadingScreenBase.SETTING_NAME):
		ProjectSettings.set_setting(LoadingScreenBase.SETTING_NAME, LoadingScreenBase.SETTING_DEFAULT_VALUE)
	ProjectSettings.set_initial_value(LoadingScreenBase.SETTING_NAME, LoadingScreenBase.SETTING_DEFAULT_VALUE)
	ProjectSettings.set_as_basic(LoadingScreenBase.SETTING_NAME, true)
	ProjectSettings.add_property_info({
		name = LoadingScreenBase.SETTING_NAME,
		type = TYPE_STRING,
		hint = PROPERTY_HINT_FILE,
		hint_string = "*.scn,*.tscn",
	})
	#endregion


func _exit_tree() -> void:
	remove_autoload_singleton("SceneManager")
