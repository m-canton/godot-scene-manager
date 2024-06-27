extends Control

@onready var change_scene_button: Button = $Panel/ChangeSceneButton

func _ready() -> void:
	change_scene_button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	var path := "res://addons/scene_manager/test/change_scene/second_scene.tscn"
	SceneManager.change_scene_to_file(path, {scene_label = "My cool scene!", cool = "does not exist"}, 1)
