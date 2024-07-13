class_name SceneManagerControl extends Control

## ModalContainer from Scene Manager plugin.
##
## Work in progress. This class opens and closes modals.
## @experimental


@export var modal_resources: Array[SceneManagerModal] = []:
	set(value):
		if modal_resources != value:
			modal_resources = value
			_update_modals()
var _modals: Array[Control] = []


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK)

## Modal scene must have a Control root.
func open_modal(node: Node, properties := {}) -> void:
	pass


func close_modal(node: Node) -> void:
	node.get_scene_instance_load_placeholder()


func register_modal(path: String) -> void:
	pass


func dissolve_to_color() -> void:
	pass


func dissolve_from_color() -> void:
	pass


func _update_modals() -> void:
	pass
