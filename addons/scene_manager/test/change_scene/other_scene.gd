extends Control

@onready var change_scene_button: Button = $Panel/VBoxContainer/ChangeSceneButton
@onready var reload_button: Button = $Panel/VBoxContainer/ReloadButton
@onready var resources_label: Label = $ResourcesLabel

var message := ""
var loading_dependency
var disable_reload_button := false

func _ready() -> void:
	$Label.text = message
	
	var scene_manager_autoload := get_node("/root/SceneManager")
	change_scene_button.pressed.connect(scene_manager_autoload.change_scene_to_file.bind("res://addons/scene_manager/test/change_scene/test_scene.tscn", {
		message = "Hello from Second Scene!"
	}))
	
	if disable_reload_button:
		reload_button.disabled = true
	else:
		reload_button.pressed.connect(scene_manager_autoload.reload_current_scene.bind({
			message = "Scene reload",
			disable_reload_button = true,
		}))
	
	if loading_dependency is Array:
		resources_label.text = "Loaded Resources:\n"
		for d in loading_dependency:
			resources_label.text += str(d) + "\n"
