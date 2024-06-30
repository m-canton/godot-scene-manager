extends Control

@onready var change_scene_button: Button = $Panel/VBoxContainer/ChangeSceneButton
@onready var reload_button: Button = $Panel/VBoxContainer/ReloadButton
@onready var dependencies_label: Label = $DependenciesLabel

var scene_label := ""
var loading_dependency
var disable_reload_button := false

func _ready() -> void:
	$Label.text = scene_label
	
	var scene_manager_autoload := get_node("/root/SceneManager")
	change_scene_button.pressed.connect(scene_manager_autoload.change_scene_to_file.bind("res://addons/scene_manager/test/change_scene/first_scene.tscn", {
		property_from_second_scene = "Hello from Second Scene!"
	}))
	
	if disable_reload_button:
		reload_button.disabled = true
	else:
		reload_button.pressed.connect(scene_manager_autoload.reload_current_scene.bind({
			scene_label = "Scene reload",
			disable_reload_button = true,
		}))
	
	if loading_dependency is Array:
		dependencies_label.text = "Dependencies:\n"
		for d in loading_dependency:
			dependencies_label.text += str(d) + "\n"
