@tool
class_name SceneTransition extends Resource

## Scene Manager Transition Resource.
## 
## Base class for Scene Manager transitions. It is used to set transitions in a
## [SceneManagerControl].
## 
## @tutorial(Transitions): https://github.com/m-canton/godot-scene-manager/wiki/Transitions

enum ColorType {
	SOLID,
	TEXTURE,
}

const SETTING_NAME_LAYER := "addons/scene_manager/transition/layer"
const DEFAULT_LAYER := 1

@export_range(0.0, 3.0, 0.25, "or_greater") var duration := 0.5
@export var color_type := ColorType.SOLID:
	set(value):
		if color_type != value:
			color_type = value
			notify_property_list_changed()
@export_color_no_alpha var color := Color.BLACK
@export var color_texture: Texture2D

@export_group("Gradient", "gradient_")
## Greyscale texture to control the top layer alpha.
@export var gradient_texture: Texture2D
## [b]Note:[/b] Only used when [member gradient_texture] is not
## [code]null[/code].
@export_range(0.0, 1.0, 0.1) var gradient_smoothness := 0.1
## [b]Note:[/b] Only used when [member gradient_texture] is not
## [code]null[/code].
@export var gradient_inverted := false
## [b]Note:[/b] Only used when [member gradient_texture] is not
## [code]null[/code].
@export var gradient_flip_h := false
## [b]Note:[/b] Only used when [member gradient_texture] is not
## [code]null[/code].
@export var gradient_flip_v := false


func _validate_property(property: Dictionary) -> void:
	if property.name == "color":
		property.usage = PROPERTY_USAGE_EDITOR if color_type == ColorType.SOLID else PROPERTY_USAGE_NO_EDITOR
	elif property.name == "color_texture":
		property.usage = PROPERTY_USAGE_EDITOR if color_type == ColorType.TEXTURE else PROPERTY_USAGE_NO_EDITOR
