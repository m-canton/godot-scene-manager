extends Control

@onready var change_scene_button: Button = $Panel/ChangeSceneButton
@onready var resources_label: Label = $ResourcesLabel

var message := ""
var loading_dependency

func _ready() -> void:
	$Label.text = message
	
	var scene_manager := get_node("/root/SceneManager")
	change_scene_button.pressed.connect(scene_manager.change_scene_to_file.bind("res://addons/scene_manager/test/change_scene/test_scene.tscn", {
		message = "Hello from Second Scene!"
	}))
	
	if loading_dependency is Array:
		resources_label.text = "Loaded Resources:\n"
		for d in loading_dependency:
			resources_label.text += str(d) + "\n"
