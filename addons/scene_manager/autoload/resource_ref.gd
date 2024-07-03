class_name SceneManagerResourceRef extends RefCounted

## LoadingScreen Dependency Reference
## 
## Class used by [SceneManager] to load resources and use them as properties.
## 
## @tutorial(Wiki): https://github.com/m-canton/godot-scene-manager/wiki

var path := "" ## Resource path.
var type_hint := "" ## Resource type hint. See [method ResourceLoader.load]
var loaded := false ## Indicates the resource is loaded.
var value: Resource = null ## Loaded resource.
