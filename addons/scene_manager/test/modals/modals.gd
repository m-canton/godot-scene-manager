extends Control

const FADE_TO_BLACK = preload("res://addons/scene_manager/test/change_scene/transition/fade_to_black.tres")
const CONICAL_TO_BLACK = preload("res://addons/scene_manager/test/change_scene/transition/conical_to_black.tres")

var _shader_tween: Tween
var _shader_tween_reverse := false
var _shader_current_image := 0

@onready var drawer_button := $HBoxContainer/DrawerButton
@onready var play_button: Button = $HBoxContainer/PlayButton
@onready var open_modal_button: Button = $HBoxContainer/OpenModalButton

@onready var backdrop: SceneManagerBackdrop = $Backdrop


func _ready() -> void:
	drawer_button.pressed.connect(_on_drawer_button_pressed)
	play_button.pressed.connect(_on_play)
	open_modal_button.pressed.connect(_on_open_modal)

func _on_play() -> void:
	process_mode = PROCESS_MODE_DISABLED
	get_node("/root/SceneManager").transition_start(FADE_TO_BLACK).finished.connect(_on_transition_finished)

func _on_transition_finished() -> void:
	get_node("/root/SceneManager").transition_start(CONICAL_TO_BLACK, true).finished.connect(_on_reverse_transition_finished)

func _on_reverse_transition_finished() -> void:
	process_mode = PROCESS_MODE_INHERIT


func _on_drawer_button_pressed() -> void:
	$DrawerBackdrop.open_modal()


func _on_open_modal() -> void:
	backdrop.open_modal()
