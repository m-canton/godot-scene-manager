extends Node


var _scenes := {}


#region Scene ID
## Last Scene ID
var _last_scene_id := 0

## Returns a new unique ID for a scene
func _generate_id() -> int:
	_last_scene_id += 1
	return _last_scene_id
#endregion


func _change_scene(id: String) -> void:
	pass


func change_scene_to_file(path: String) -> void:
	pass


func change_scene_to_packed_scene(path: String) -> void:
	pass
