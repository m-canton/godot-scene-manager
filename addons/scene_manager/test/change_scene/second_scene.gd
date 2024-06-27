extends Control


@onready var change_scene_button: Button = $Panel/ChangeSceneButton

var scene_label := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.text = scene_label
	
	change_scene_button.pressed.connect(func():
		SceneManager.change_scene_to_file("res://addons/scene_manager/test/change_scene/first_scene.tscn")
	)
