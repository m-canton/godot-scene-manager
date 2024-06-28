class_name LoadingScreenBase extends Control

## LoadingScreen base class
## 
## Extend this class and override methods to create a custom loading screen.
## Change "addons/scene_manager/loading_screen" Project setting to load your
## scene.[br]
## You can override [method _get_range_node], [method _get_tween_duration] and
## [method handle_load_error] to customize.

## Loading Screen setting name.
const SETTING_NAME := "addons/scene_manager/loading_screen"
## Default Loading Screen scene path.
const SETTING_DEFAULT_VALUE := "res://addons/scene_manager/autoload/loading_screen.tscn"

## Property used to store the tween which does smooth progress change.
var _range_tween: Tween

#region Overrideable methods
## Range node to show the progress. Override the method to change the node.[br]
## This node must have [code]value[/code] property to show the progress.
func _get_range_node() -> Node:
	return get_node("ProgressBar")

## Time it takes to reach the new value. Override the method to change the
## value. If the value is 0.0 or negative, it sets property immediately.
func _get_tween_duration() -> float:
	return 0.25

## Handle the load scene error. It is called when the scene cannot be loaded due
## to some error. You can override this method to show an error on screen.
func handle_load_error() -> void:
	push_error("Scene load error. Override LoadingScreenBase.handle_load_error to show error on your custom screen.")
#endregion

## Percent must be a value between 0.0 and 100.0. Ensure your custom range
## node has a [code]value[/code] property with float values between 0 and 100.
func set_progress(percent: float) -> void:
	var tween_duration := _get_tween_duration()
	
	var range := _get_range_node()
	if "value" in range:
		if tween_duration > 0.0:
			if _range_tween and _range_tween.is_running():
				_range_tween.kill()
			
			_range_tween = range.create_tween()
			_range_tween.tween_property(range, "value", percent, tween_duration)
		else:
			range.value = percent
	else:
		push_warning("'value' property doesn't exist.")
