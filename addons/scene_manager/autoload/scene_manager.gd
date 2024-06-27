extends Node

## SceneManager Autoload
## 
## This autoload allows to change scenes and set properties when instance is
## created.
## 
## @experimental

## Default Loading Screen scene path.
const LOADING_SCREEN_PATH := "res://addons/scene_manager/autoload/loading_screen.tscn"
## Loading Screen setting name.
const LOADING_SCREEN_NAME_SETTING := "addons/scene_manager/loading_screen"


func _ready() -> void:
	get_tree().root.child_entered_tree.connect(_on_child_entered_tree)
	get_tree().root.child_exiting_tree.connect(_on_child_existing_tree)
	
	_packed_loading_screen = load(ProjectSettings.get_setting(LOADING_SCREEN_NAME_SETTING, LOADING_SCREEN_PATH))


func _process(delta: float) -> void:
	if _loading:
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
		
		if not _min_duration_completed:
			_loading_screen_min_duration -= delta
			if _loading_screen_min_duration <= 0.0:
				_min_duration_completed = true
				if _packed_scene:
					_on_scene_loaded(_packed_scene)


#region Loading Screen
var _loading := false
var _packed_scene: PackedScene
var _min_duration_completed := true
var _loading_screen_min_duration := 0.0

var _loading_screen: LoadingScreenBase
var _packed_loading_screen: PackedScene

## Show loading screen.
func _load_scene(path: String, min_duration: float) -> Error:
	_loading_screen_min_duration = max(min_duration, 0.0)
	var error := ResourceLoader.load_threaded_request(path, "PackedScene")
	if error:
		push_error("Error changing scene to file: %s. %s" % [path, error_string(error)])
		_on_scene_loaded(null)
		return error
	
	_min_duration_completed = false
	
	get_tree().change_scene_to_packed(_packed_loading_screen)
	_loading = true
	return OK

## Set loading screen progress.
func _loading_screen_set_progress(percent: float) -> void:
	if _loading_screen:
		_loading_screen.set_progress(percent)

## Hide loading screen.
func _on_scene_loaded(packed_scene: PackedScene) -> Error:
	if packed_scene and not _min_duration_completed:
		_packed_scene = packed_scene
		return OK
	
	_loading = false
	_packed_scene = null
	_loading_screen_min_duration = 0.0
	
	if not packed_scene:
		_loading_scene_path = ""
		_loading_scene_properties = {}
		if _loading_screen:
			_loading_screen.handle_load_error()
		return FAILED
	
	return get_tree().change_scene_to_packed(packed_scene)
#endregion


#region Change Scene
var _loading_scene_path := ""
var _loading_scene_properties := {}

## Update properties when next scene entered tree.
func _on_child_entered_tree(node: Node) -> void:
	# Skip LoadingScreenBase node.
	if node is LoadingScreenBase:
		_loading_screen = node
	else:
		for property in _loading_scene_properties:
			if property in node:
				node.set(property, _loading_scene_properties[property])
			else:
				push_warning("Property '%s' does not exist in %s." % [property, node.to_string()])
		_loading_scene_properties = {}

func _on_child_existing_tree(node: Node) -> void:
	if node is LoadingScreenBase:
		_loading_screen = null


## Change scene using scene file path.[br]
## Set a positive float on [param min_loading_duration] for background loading.
## (WIP) Loading screen is pending to add.
## @experimental
func change_scene_to_file(path: String, properties := {}, min_duration := 0.0) -> Error:
	if path.is_empty() or not ResourceLoader.exists(path):
		return ERR_DOES_NOT_EXIST
	
	if get_tree().current_scene.scene_file_path == path:
		push_warning("This scene is already loaded. Use SceneManager.reload_current_scene instead.")
		return ERR_ALREADY_EXISTS
	
	_loading_scene_path = path
	_loading_scene_properties = properties
	if min_duration > 0.0:
		return _load_scene(path, min_duration)
	
	var error := get_tree().change_scene_to_file(path)
	if error:
		push_error("Error loading scene: " + path)
		_on_scene_loaded(null)
		return ERR_CANT_OPEN
	return OK

## Change scene using a packed scene.
func change_scene_to_packed_scene(packed_scene: PackedScene, properties := {}) -> Error:
	if packed_scene:
		_loading_scene_path = packed_scene.resource_path
	_loading_scene_properties = properties
	_on_scene_loaded(packed_scene)
	return OK

## Reload current scene. [param properties] is the initial properties.
func reload_current_scene(properties := {}) -> Error:
	_loading_scene_properties = properties
	var error := get_tree().reload_current_scene()
	return error

func _reset_data(full := false) -> void:
	if full:
		_loading_scene_path = ""
		_loading_scene_properties = {}
	_loading_screen_min_duration = 0.0
#endregion
