@tool
class_name SceneManagerModalContainer extends Container

## ModalContainer from Scene Manager plugin.
##
## Work in progress. This class opens and closes modals.
## @experimental


@export var modal_resources: Array[SceneManagerModalResource] = []:
	set(value):
		if modal_resources != value:
			modal_resources = value
			_update_modals()
var _modals: Array[Control] = []


func _notification(what: int) -> void:
	if what == NOTIFICATION_PRE_SORT_CHILDREN:
		for c in get_children():
			if c is Control:
				fit_child_in_rect(c, Rect2(Vector2.ZERO, size))


## Modal scene must have a Control root.
func open_modal(node: Node, properties := {}) -> void:
	pass


func close_modal(node: Node) -> void:
	node.get_scene_instance_load_placeholder()


func register_modal(path: String) -> void:
	pass


func _update_modals() -> void:
	pass
