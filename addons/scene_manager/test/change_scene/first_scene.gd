extends Control

@export_group("Test", "test_")
## Loading screen minimum duration.
@export_range(0.0, 3.0) var test_background_loading_min_duration := 0.5
## Text shown on second scene.
@export var test_second_scene_label_text := "My cool scene!"
## Add a variable which does not exist in second scene to raise a warning.
@export var test_property_does_not_exist := false
## label_text value for loading screen. You must use
## scene_manager/test/custom_loading_screen/loading_screen.tscn
## as your loading screen in project settings or other LoadinScreenBase with
## this property.
@export var test_loading_screen_label_text := ""

@onready var change_scene_button: Button = $Panel/VBoxContainer/ChangeSceneButton

func _ready() -> void:
	change_scene_button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	var path := "res://addons/scene_manager/test/change_scene/second_scene.tscn"
	
	var properties := {
		scene_label = test_second_scene_label_text,
	}
	
	if (test_property_does_not_exist):
		properties["cool"] = "does not exist"
	
	var loading_properties := {}
	if (not test_loading_screen_label_text.is_empty()):
		loading_properties["label_text"] = test_loading_screen_label_text
	
	get_node("/root/SceneManager").change_scene_to_file(path, properties, test_background_loading_min_duration, loading_properties)
