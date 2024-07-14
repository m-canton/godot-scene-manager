extends PanelContainer

@onready var return_button: Button = $VBoxContainer/ReturnButton

func _ready() -> void:
	return_button.pressed.connect(get_node("/root/SceneManager").change_scene_to_file.bind("res://addons/scene_manager/test/change_scene/test_scene.tscn"))
