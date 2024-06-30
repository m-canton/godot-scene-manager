class_name LoadingScreenDependencyRef extends RefCounted

## LoadingScreen Dependency Reference
## 
## Class used by SceneManager to load resources and use them as properties.

## Resource path.
var path := ""
## Resource type hint.
var type_hint := ""
## Indicates the resource is loaded.
var loaded := false
## Resource instance.
var value: Variant = null
