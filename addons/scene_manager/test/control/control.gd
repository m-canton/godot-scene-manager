extends SceneManagerControl

const FADE_TO_BLACK = preload("res://addons/scene_manager/test/change_scene/transition/fade_to_black.tres")
const CONICAL_TO_BLACK = preload("res://addons/scene_manager/test/change_scene/transition/conical_to_black.tres")

var _shader_tween: Tween
var _shader_tween_reverse := false
var _shader_current_image := 0

@onready var back_button := $HBoxContainer/BackButton
@onready var play_button: Button = $HBoxContainer/PlayButton

@export var duration := 0.5


func _ready() -> void:
	get_node("/root/SceneManager").set_control(self)
	back_button.pressed.connect(get_node("/root/SceneManager").change_scene_to_file.bind("res://addons/scene_manager/test/change_scene/test_scene.tscn"))
	play_button.pressed.connect(_on_play)


func _on_play() -> void:
	process_mode = PROCESS_MODE_DISABLED
	get_node("/root/SceneManager").transition_start(FADE_TO_BLACK).finished.connect(_on_transition_finished)

func _on_transition_finished() -> void:
	get_node("/root/SceneManager").transition_start(CONICAL_TO_BLACK, true).finished.connect(_on_reverse_transition_finished)

func _on_reverse_transition_finished() -> void:
	process_mode = PROCESS_MODE_INHERIT
