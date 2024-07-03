extends Node

## SceneManager Autoload
## 
## This autoload allows to change scenes and set properties when instance is
## created.[br]
## This autload uses [LoadingScreen] for background loading. You can
## extend this class to make a custom loading screen.[br]
## [b]Note:[/b] Using [LoadingScreen] for other purposes may break the
## loading functionality.
## 
## @tutorial(Wiki): https://github.com/m-canton/godot-scene-manager/wiki


#region Virtual Methods
func _ready() -> void:
	set_process(false)
	set_loading_screen(ProjectSettings.get_setting(LoadingScreen.SETTING_NAME, LoadingScreen.SETTING_DEFAULT_VALUE), LoadingScreen.Type.DEFAULT)
	
	get_tree().root.child_entered_tree.connect(_on_child_entered_tree)
	get_tree().root.child_exiting_tree.connect(_on_child_existing_tree)


func _process(delta: float) -> void:
	if _loading:
		if not _min_duration_completed:
			_loading_screen_min_duration -= delta
			if _loading_screen_min_duration <= 0.0:
				_min_duration_completed = true
				if _dependencies_are_loaded:
					_on_scene_loaded()
		
		if not _dependencies_are_loaded:
			var progress := []
			var status := ResourceLoader.load_threaded_get_status(_current_dependency.path, progress)
			if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				if _loading_screen_min_duration > 0.0:
					_loading_screen_set_progress(progress[0])
			elif status == ResourceLoader.THREAD_LOAD_LOADED:
				_loading_screen_set_progress(100.0 * float(_current_dependency_index + 1) / float(_loading_dependencies.size()))
				_current_dependency.value = ResourceLoader.load_threaded_get(_current_dependency.path)
				_current_dependency.loaded = true
				
				if _load_next_resource() == OK and _dependencies_are_loaded:
					_on_scene_loaded()
			elif status == ResourceLoader.THREAD_LOAD_FAILED:
				push_error("Load failed: " + _current_dependency.path)
				_on_load_error()
			elif status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				push_error("Invalid resource: " +  _current_dependency.path)
				_on_load_error()
#endregion


#region Change Scene
## Enum used to reset inner variables.
enum LoadingProperties {
	ALL, ## All the variables.
	LOADING_SCREEN_AFTER, ## After adding the loading screen scene.
	BEFORE, ## When scene is loaded.
	AFTER, ## After adding the loaded scene.
}

## Next scene properties to set when the scene is .
var _loading_scene_properties := {}
## Loading dependencies queue.
var _loading_dependencies: Array[SceneManagerResourceRef] = []
var _current_dependency: SceneManagerResourceRef
var _current_dependency_index := -1:
	set(value):
		if _current_dependency_index != value:
			_current_dependency_index = value
			if _current_dependency_index >= 0 and _current_dependency_index < _loading_dependencies.size():
				_current_dependency = _loading_dependencies[_current_dependency_index]
			else:
				_current_dependency = null

## Resets all the properties in SceneManager.
func clear_options() -> void:
	_reset_loading_properties()

## Changes scene using scene file path.[br]
## Sets a positive float on [param min_duration] for using a loading
## screen. You can set properties in loading screen with
## [param loading_properties].
func change_scene_to_file(path: String, properties := {}, min_duration := 0.0, loading_properties := {}) -> Error:
	if _loading:
		return FAILED
	
	if path.is_empty() or not ResourceLoader.exists(path):
		push_error("Scene does not exist: ", path)
		_on_load_error()
		return ERR_DOES_NOT_EXIST
	
	var tree := get_tree()
	if tree.current_scene.scene_file_path == path:
		push_warning("This scene is already loaded. Use SceneManager.reload_current_scene instead.")
		return ERR_ALREADY_EXISTS
	
	_loading_scene_properties = properties
	if min_duration > 0.0:
		_loading_screen_properties = loading_properties
		return _load_scene(path, min_duration)
	
	_current_dependency = SceneManagerResourceRef.new()
	_current_dependency.path = path
	
	var error := tree.change_scene_to_file(path)
	if error:
		push_error("Error loading scene: " + path)
		_on_load_error()
		return error
	
	_reset_loading_properties(LoadingProperties.LOADING_SCREEN_AFTER)
	_reset_loading_properties(LoadingProperties.BEFORE)
	
	return OK

## Changes scene using a packed scene.
func change_scene_to_packed(packed_scene: PackedScene, properties := {}) -> Error:
	if _loading:
		return FAILED
	
	_loading_scene_properties = properties
	_current_dependency = SceneManagerResourceRef.new()
	_current_dependency.path = packed_scene.resource_path
	_current_dependency.value = packed_scene
	
	var error := get_tree().change_scene_to_packed(packed_scene)
	if error:
		push_error(error_string(error))
		_on_load_error()
		return error
	
	return OK

## Reloads current scene. [param properties] is the initial properties.
func reload_current_scene(properties := {}) -> Error:
	if _loading:
		return FAILED
	
	var tree := get_tree()
	_current_dependency = SceneManagerResourceRef.new()
	_current_dependency.path = tree.current_scene.scene_file_path
	_loading_scene_properties = properties
	var error := tree.reload_current_scene()
	if error:
		_reset_loading_properties(LoadingProperties.AFTER)
	return error

## Resets loading properties to default values.
func _reset_loading_properties(what := LoadingProperties.ALL) -> void:
	if what == LoadingProperties.ALL || what == LoadingProperties.LOADING_SCREEN_AFTER:
		if not _loading_screen_persistent:
			_packed_loading_screen = _default_packed_loading_screen
		_loading_screen_properties = {}
	
	if what == LoadingProperties.ALL || what == LoadingProperties.BEFORE:
		_loading = false
		_loading_screen = null
		_loading_screen_min_duration = 0.0
		_min_duration_completed = true
		_dependencies_are_loaded = true
		_valid_properties = []
	
	if what == LoadingProperties.ALL || what == LoadingProperties.AFTER:
		_loading_dependencies = []
		_current_dependency_index = -1
		_loading_scene_properties = {}

## Updates properties when next scene is entered to the tree. Also adds
## loading screen instance reference.
func _on_child_entered_tree(node: Node) -> void:
	var properties := {}
	if node is LoadingScreen:
		_loading_screen = node
		properties = _loading_screen_properties
		_reset_loading_properties(LoadingProperties.LOADING_SCREEN_AFTER)
	elif _current_dependency is SceneManagerResourceRef and node.scene_file_path == _current_dependency.path:
		properties = _loading_scene_properties
		_reset_loading_properties(LoadingProperties.AFTER)
	else:
		return
	
	for property in properties:
		if property in node:
			node.set(property, properties[property])
		else:
			push_warning("Property '%s' does not exist in %s." % [property, node.to_string()])

## Removes loading screen instance reference.
func _on_child_existing_tree(node: Node) -> void:
	if node is LoadingScreen:
		_loading_screen = null
#endregion


#region Loading Screen
## Indicates whether a scene is currently being loaded.[br]
## Only used with background loading.
var _loading := false
## Loading screen properties. When the loading screen scene enters to the tree,
## this properties are set.
var _loading_screen_properties := {}
## Minimum duration (in seconds) that the loading screen should be displayed.[br]
## If this is [code]0.0[/code], the packed scene is not background loaded.
var _loading_screen_min_duration := 0.0
## Ensures that a minimum duration has passed before completing the loading
## process.[br]
## Only used with background loading.
var _min_duration_completed := true
## Current loading screen instance.
var _loading_screen: LoadingScreen
## Default loading screen PackedScene.
var _default_packed_loading_screen: PackedScene
## Current loading screen PackedScene.
var _packed_loading_screen: PackedScene
## Indicates if current loading screen is persist.
var _loading_screen_persistent := true
## Property sets with parsed [SceneManagerResourceRef] values.[br]
## Only used with background loading.
var _valid_properties := []
## Indicates all the dependencies are loaded.
## See [member _loading_dependencies].
var _dependencies_are_loaded := true

## Sets current loading screen. See [method set_loading_screen_from_packed].
func set_loading_screen(path: String, type := LoadingScreen.Type.ONE_SHOT) -> void:
	set_loading_screen_from_packed(load(path), type)

## Sets current loading screen. You can change the default loading screen or
## keeps it for other subsequent loads by changing [param type] param. To set
## the default scene, you can use the reset_loading_screen method.
func set_loading_screen_from_packed(packed_scene: PackedScene, type := LoadingScreen.Type.ONE_SHOT) -> void:
	if not packed_scene:
		push_error("'packed_scene' cannot be null. Use SceneManager.reset_loading_screen to set the default loading screen.")
	
	if type == LoadingScreen.Type.DEFAULT:
		_default_packed_loading_screen = packed_scene
	
	_loading_screen_persistent = type == LoadingScreen.Type.PERSIST
	
	_packed_loading_screen = packed_scene

## Returns loading screen to default loading screen. Sets the last loading
## screen with [const LoadingScreenFlags.DEFAULT] flag.
func reset_loading_screen() -> void:
	_packed_loading_screen = _default_packed_loading_screen
	_loading_screen_persistent = false

## Appends a loading dependency and returns a [SceneManagerResourceRef]. Use
## this in your properties to pass to next scene. Loading dependencies are
## loaded on background and parses properties.[br]
## [b]Note:[/b] This just works using [method change_scene_to_file] with
## [code]min_duration > 0.0[/code].[br]
## [b]Note:[/b] It just can parse values within arrays and dictionaries. Does
## not parse the object properties.
## @experimental
func append_resource(dependency_path: String, type_hint: String = "") -> SceneManagerResourceRef:
	for ref in _loading_dependencies:
		if ref.path == dependency_path:
			push_warning("Resource is already added to load.")
			return ref
	
	if not ResourceLoader.exists(dependency_path, type_hint):
		push_error("Resource does not exist: ", dependency_path)
		return null
	
	var dependency_ref := SceneManagerResourceRef.new()
	dependency_ref.path = dependency_path
	dependency_ref.type_hint = type_hint
	_loading_dependencies.append(dependency_ref)
	
	return dependency_ref

## Loads the next resource.
func _load_next_resource() -> Error:
	if _current_dependency_index + 1 < _loading_dependencies.size():
		_current_dependency_index += 1
		var error := ResourceLoader.load_threaded_request(_current_dependency.path, _current_dependency.type_hint)
		if error:
			push_error(error_string(error))
		return error
	_dependencies_are_loaded = true
	return OK

## Replaces all the [SceneManagerResourceRef]s by their values.[br]
## [b]Note:[/b] [param properties] must be [Array] or [Dictionary].
## @experimental
func _parse_properties(properties) -> void:
	if properties in _valid_properties:
		return # Avoid cyclic reference
	
	_valid_properties.append(properties)
	
	if properties is Array:
		for i in range(properties.size()):
			var value = properties[i]
			if value is SceneManagerResourceRef:
				properties[i] = value.value
			elif value is Array or value is Dictionary:
				_parse_properties(value)
	elif properties is Dictionary:
		for key in properties.keys():
			var value = properties[key]
			if value is SceneManagerResourceRef:
				properties[key] = value.value
			elif value is Array or value is Dictionary:
				_parse_properties(value)
	else:
		push_warning("'properties' no valid: ", str(properties))

## Shows loading screen.
func _load_scene(path: String, min_duration: float) -> Error:
	_loading_screen_min_duration = max(min_duration, 0.0)
	
	if not append_resource(path, "PackedScene"):
		push_error("Error changing scene to file: %s" % [path])
		_on_load_error()
		return FAILED
	
	_loading = true
	_min_duration_completed = false
	_dependencies_are_loaded = false
	set_process(true)
	
	get_tree().change_scene_to_packed(_packed_loading_screen)
	
	return _load_next_resource()

## Sets loading screen progress.
func _loading_screen_set_progress(percent: float) -> void:
	if _loading_screen:
		_loading_screen.set_progress(percent)

## Hides loading screen.
func _on_scene_loaded() -> Error:
	if _dependencies_are_loaded and not _min_duration_completed:
		return OK
	
	if not _current_dependency is SceneManagerResourceRef or not _current_dependency.value is PackedScene:
		_on_load_error()
		return FAILED
	
	set_process(false)
	_parse_properties(_loading_scene_properties)
	_reset_loading_properties(LoadingProperties.BEFORE)
	
	return get_tree().change_scene_to_packed(_current_dependency.value)


func _on_load_error() -> void:
	_reset_loading_properties(LoadingProperties.ALL)
	if _loading_screen:
		_loading_screen.handle_load_error()
#endregion
