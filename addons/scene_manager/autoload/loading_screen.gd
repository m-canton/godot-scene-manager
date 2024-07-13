class_name LoadingScreen extends Control

## LoadingScreen base class
## 
## Extend this class and override methods to create a custom loading screen.
## Change "addons/scene_manager/loading_screen" Project setting to load your
## scene.[br]
## You can override [method _get_range_object], [method _get_tween_duration] and
## [method handle_load_error] to customize.
## 
## @tutorial(Loading Screens): https://github.com/m-canton/godot-scene-manager/wiki/Background-Loading#loading-screens

## Default Loading Screen scene path.
const DEFAULT_PATH := "res://addons/scene_manager/autoload/loading_screen.tscn"
## Loading screen default path setting name.
const SETTING_NAME_DEFAULT_PATH := "addons/scene_manager/loading_screen/default_scene_path"
## Print loading times setting name.
const SETTING_NAME_PRINT_LOADING_TIMES := "addons/scene_manager/loading_screen/print_loading_times"

## Loading Screen type.
enum Type {
	DEFAULT, ## Default loading screen.
	PERSIST, ## Used it on next loads until other loading screen is set. Use [method SceneManager.reset_loading_screen] to set the default loading screen.
	ONE_SHOT, ## Used it on one load. After setting the default loading screen.
}

## Property used to store the tween which does smooth progress change.
var _range_tween: Tween
## Indicates if range_object object has [code]value[/code] property.
var _range_object_exists_value := true

#region Overrideable methods
## An object with a [code]value[/code] property to update with float values
## between 0.0 and 100.0 with [method set_progress]. Override the method to
## change the object.[br]
## Return null to not use this feature.
func _get_range_object() -> Object:
	return get_node_or_null("ProgressBar")

## Time it takes to reach the new value. Override the method to change the
## value. If the value is 0.0 or negative, it sets property immediately.
func _get_tween_duration() -> float:
	return 0.25

## Handle the load scene error. It is called when the scene cannot be loaded due
## to some error. You can override this method to show an error on screen.
func handle_load_error() -> void:
	push_error("Scene load error. Override LoadingScreenBase.handle_load_error to show error on your custom screen.")
#endregion

## Percent must be a value between 0.0 and 100.0. Ensure your custom range_object
## node has a [code]value[/code] property with float values between 0 and 100.
func set_progress(percent: float) -> void:
	var range_object := _get_range_object()
	if not range_object:
		return
	
	var tween_duration := _get_tween_duration()
	
	if "value" in range_object:
		if tween_duration > 0.0:
			if _range_tween and _range_tween.is_running():
				_range_tween.kill()
			
			_range_tween = self.create_tween()
			_range_tween.tween_property(range_object, "value", percent, tween_duration)
		else:
			range_object.value = percent
	elif _range_object_exists_value:
		_range_object_exists_value = false
		push_warning("'value' property doesn't exist in %s." % range_object.to_string())
