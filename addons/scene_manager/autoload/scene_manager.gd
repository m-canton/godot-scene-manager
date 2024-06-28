extends Node

## SceneManager Autoload
## 
## This autoload allows to change scenes and set properties when instance is
## created.[br]
## This autload uses [LoadingScreenBase] for background loading. You can
## extend this class to make a custom loading screen.[br]
## [b]Note:[/b] Using [LoadingScreenBase] for other purposes may break the
## loading functionality.
## 
## @tutorial(GitHub Repository): https://github.com/m-canton/godot-scene-manager


enum LoadingProperties {
	BEFORE,
	AFTER,
	BOTH,
}


func _ready() -> void:
	get_tree().root.child_entered_tree.connect(_on_child_entered_tree)
	get_tree().root.child_exiting_tree.connect(_on_child_existing_tree)
	
	var path := ProjectSettings.get_setting(LoadingScreenBase.SETTING_NAME, LoadingScreenBase.SETTING_DEFAULT_VALUE)
	_loading_screen_packed_scene = load(path)


func _process(delta: float) -> void:
	if _loading:
		if not _min_duration_completed:
			_loading_screen_min_duration -= delta
			if _loading_screen_min_duration <= 0.0:
				_min_duration_completed = true
				if _packed_scene:
					_on_scene_loaded(_packed_scene)
		
		if not _packed_scene:
			var progress := []
			var status := ResourceLoader.load_threaded_get_status(_loading_scene_path, progress)
			if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				if _loading_screen_min_duration > 0.0:
					_loading_screen_set_progress(progress[0])
			elif status == ResourceLoader.THREAD_LOAD_LOADED:
				_loading_screen_set_progress(100)
				_on_scene_loaded(ResourceLoader.load_threaded_get(_loading_scene_path))
			elif status == ResourceLoader.THREAD_LOAD_FAILED:
				push_error("Load failed: " + _loading_scene_path)
				_on_scene_loaded(null)
			elif status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				push_error("Invalid resource: " + _loading_scene_path)
				_on_scene_loaded(null)


#region Change Scene
## Next scene properties to set when the scene is .
var _loading_scene_properties := {}

## Update properties when next scene is entered to the tree. Also add
## loading screen instance reference.
func _on_child_entered_tree(node: Node) -> void:
	if node is LoadingScreenBase:
		_loading_screen_instance = node
	elif node == _packed_scene || node.scene_file_path == _loading_scene_path:
		for property in _loading_scene_properties:
			if property in node:
				node.set(property, _loading_scene_properties[property])
			else:
				push_warning("Property '%s' does not exist in %s." % [property, node.to_string()])
		_reset_loading_properties(LoadingProperties.AFTER)

## Remove loading screen instance reference.
func _on_child_existing_tree(node: Node) -> void:
	if node is LoadingScreenBase:
		_loading_screen_instance = null

## Change scene using scene file path.[br]
## Set a positive float on [param min_loading_duration] for using a loading
## screen.
func change_scene_to_file(path: String, properties := {}, min_duration := 0.0) -> Error:
	if _loading:
		return FAILED
	
	if path.is_empty() or not ResourceLoader.exists(path):
		return ERR_DOES_NOT_EXIST
	
	var tree := get_tree()
	if tree.current_scene.scene_file_path == path:
		push_warning("This scene is already loaded. Use SceneManager.reload_current_scene instead.")
		return ERR_ALREADY_EXISTS
	
	_loading_scene_properties = properties
	if min_duration > 0.0:
		return _load_scene(path, min_duration)
	
	var error := tree.change_scene_to_file(path)
	if error:
		push_error("Error loading scene: " + path)
		_on_scene_loaded(null)
		return ERR_CANT_OPEN
	
	_loading_scene_path = path
	
	return OK

## Change scene using a packed scene.
func change_scene_to_packed_scene(packed_scene: PackedScene, properties := {}) -> Error:
	if _loading:
		return FAILED
	
	_loading_scene_properties = properties
	_on_scene_loaded(packed_scene)
	return OK

## Reload current scene. [param properties] is the initial properties.
func reload_current_scene(properties := {}) -> Error:
	if _loading:
		return FAILED
	
	_loading_scene_properties = properties
	var error := get_tree().reload_current_scene()
	return error

## Reset loading properties to default values.
func _reset_loading_properties(what := LoadingProperties.BOTH) -> void:
	if what == LoadingProperties.BOTH || what == LoadingProperties.BEFORE:
		_loading = false
		_loading_screen_instance = null
		_loading_screen_min_duration = 0.0
		_min_duration_completed = true
	
	if what == LoadingProperties.BOTH || what == LoadingProperties.AFTER:
		_packed_scene = null
		_loading_scene_path = ""
		_loading_scene_properties = {}
#endregion


#region Background Loading Screen
## Indicates whether a scene is currently being loaded.[br]
## Only used with background loading.
var _loading := false
## Scene file path of the scene that is currently being loaded.[br]
## Only used with background loading.
var _loading_scene_path := ""
## Minimum duration (in seconds) that the loading screen should be displayed.[br]
## If this is [code]0.0[/code], the packed scene is not background loaded.
var _loading_screen_min_duration := 0.0
## Ensures that a minimum duration has passed before completing the loading
## process.[br]
## Only used with background loading.
var _min_duration_completed := true

## Current loading screen instance.
var _loading_screen_instance: LoadingScreenBase
## PackedScene for the loading screen.
var _loading_screen_packed_scene: PackedScene
## PackedScene for the loaded scene. Only used with background loading.
var _packed_scene: PackedScene

## Show loading screen.
func _load_scene(path: String, min_duration: float) -> Error:
	_loading_scene_path = path
	_loading_screen_min_duration = max(min_duration, 0.0)
	var error := ResourceLoader.load_threaded_request(path, "PackedScene")
	if error:
		push_error("Error changing scene to file: %s. %s" % [path, error_string(error)])
		_on_scene_loaded(null)
		return error
	
	_min_duration_completed = false
	
	get_tree().change_scene_to_packed(_loading_screen_packed_scene)
	_loading = true
	return OK

## Set loading screen progress.
func _loading_screen_set_progress(percent: float) -> void:
	if _loading_screen_instance:
		_loading_screen_instance.set_progress(percent)

## Hide loading screen.
func _on_scene_loaded(packed_scene: PackedScene) -> Error:
	_packed_scene = packed_scene
	if packed_scene and not _min_duration_completed:
		return OK
	
	if packed_scene:
		_reset_loading_properties(LoadingProperties.BEFORE)
	else:
		_reset_loading_properties(LoadingProperties.BOTH)
		if _loading_screen_instance:
			_loading_screen_instance.handle_load_error()
		return FAILED
	
	return get_tree().change_scene_to_packed(packed_scene)
#endregion
