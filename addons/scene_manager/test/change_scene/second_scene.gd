extends Control

@onready var change_scene_button: Button = $Panel/VBoxContainer/ChangeSceneButton
@onready var reload_button: Button = $Panel/VBoxContainer/ReloadButton

var scene_label := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.text = scene_label
	
	change_scene_button.pressed.connect(SceneManager.change_scene_to_file.bind("res://addons/scene_manager/test/change_scene/first_scene.tscn"))
	reload_button.pressed.connect(SceneManager.reload_current_scene.bind({
		scene_label = "Scene reload"
	}))
