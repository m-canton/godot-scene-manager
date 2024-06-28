extends Control

@export_group("Test", "test_")
## Loading screen minimum duration.
@export_range(0.0, 3.0) var test_background_loading_min_duration := 0.5
## Text shown on second scene.
@export var test_second_scene_label_text := "My cool scene!"
## Add a variable which does not exist in second scene to raise a warning.
@export var test_property_does_not_exist := false

@onready var change_scene_button: Button = $Panel/ChangeSceneButton

func _ready() -> void:
	change_scene_button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	var path := "res://addons/scene_manager/test/change_scene/second_scene.tscn"
	
	var properties := {
		scene_label = test_second_scene_label_text,
	}
	
	if (test_property_does_not_exist):
		properties["cool"] = "does not exist"
	
	SceneManager.change_scene_to_file(path, properties, test_background_loading_min_duration)
