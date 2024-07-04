extends Control

@onready var change_scene_button: Button = $Panel/ChangeSceneButton
@onready var resources_label: Label = $ResourcesLabel

var message := ""
var loaded_resources

func _ready() -> void:
	$Label.text = message
	
	change_scene_button.pressed.connect(get_node("/root/SceneManager").change_scene_to_file.bind("res://addons/scene_manager/test/change_scene/test_scene.tscn", {
		message = "Hello from Second Scene!"
	}))
	
	# Loaded resources
	if loaded_resources is Array:
		resources_label.text = "Loaded Resources:\n"
		for d in loaded_resources:
			resources_label.text += str(d) + "\n"
