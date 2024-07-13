class_name SceneManagerResourceRef extends RefCounted

## LoadingScreen Dependency Reference
## 
## Class used by [SceneManager] to load resources and use them as properties.
## 
## @tutorial(Appending Resources): https://github.com/m-canton/godot-scene-manager/wiki/Background-Loading#appending-resources

var path := "" ## Resource path.
var type_hint := "" ## Resource type hint. See [method ResourceLoader.load]
var cache_mode := ResourceLoader.CACHE_MODE_REUSE
var loaded := false ## Indicates the resource is loaded.
var value: Resource = null ## Loaded resource.
