extends Control

const FADE_TO_BLACK = preload("res://addons/scene_manager/test/change_scene/transition/fade_to_black.tres")
const RADIAL_TO_BLACK = preload("res://addons/scene_manager/test/change_scene/transition/radial_to_black.tres")

var message := ""

@onready var source_option_button: OptionButton = %ChageSceneContainer/Controls/SourceControl/OptionButton
@onready var message_line_edit: LineEdit = %ChageSceneContainer/Controls/MessageControl/LineEdit

@onready var loading_screen_scene_option_button: OptionButton = %LoadingScreenContainer/Controls/SceneControl/OptionButton
@onready var loading_screen_min_duration_slider: HSlider = %LoadingScreenContainer/Controls/MinDurationControl/HSlider
@onready var loading_screen_message_line_edit: LineEdit = %LoadingScreenContainer/Controls/MessageControl/LineEdit
@onready var loading_screen_append_resources_check_button: CheckButton = %LoadingScreenContainer/AppendResourcesControl/CheckButton

@onready var modals_button: Button = $ColorRect/VBoxContainer/MessageMarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/ModalsButton
@onready var reload_scene_button = $ColorRect/VBoxContainer/MessageMarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/ReloadSceneButton
@onready var change_scene_button: Button = $ColorRect/VBoxContainer/MessageMarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/ChangeSceneButton

@onready var message_label: Label = $ColorRect/VBoxContainer/MessageMarginContainer/VBoxContainer/MessageLabel

func _ready() -> void:
	process_mode = PROCESS_MODE_DISABLED
	get_node("/root/SceneManager").transition_start(FADE_TO_BLACK, true).finished.connect(func():
		process_mode = PROCESS_MODE_INHERIT
	)
	
	var style_box: StyleBoxFlat = message_label.get_theme_stylebox("normal")
	style_box.bg_color = Color("#262b34")
	if not message.is_empty():
		var tween := create_tween()
		message_label.text = message
		tween.tween_property(style_box, "bg_color", Color("#cf641c"), 0.1)
		tween.tween_property(style_box, "bg_color", Color("#262b34"), 0.5).set_delay(0.5)
	
	_on_source_selected(source_option_button.selected)
	source_option_button.item_selected.connect(_on_source_selected)
	
	_on_loading_screen_scene_selected(loading_screen_scene_option_button.selected)
	loading_screen_scene_option_button.item_selected.connect(_on_loading_screen_scene_selected)
	
	modals_button.pressed.connect(_on_modals_button_pressed)
	reload_scene_button.pressed.connect(_on_reload_scene)
	change_scene_button.pressed.connect(_fade_to_change_scene)


func _on_reload_scene() -> void:
	get_node("/root/SceneManager").reload_current_scene({
		message = "Scene reloaded!"
	})


func _fade_to_change_scene() -> void:
	process_mode = PROCESS_MODE_DISABLED
	get_node("/root/SceneManager").transition_start(RADIAL_TO_BLACK).finished.connect(_on_change_scene)


func _on_change_scene() -> void:
	var path := "res://addons/scene_manager/test/change_scene/other_scene.tscn"
	
	var properties := { message = message_line_edit.text }
	
	# It is used get_node because SceneManager is not autoload if plugin is
	# disabled.
	var scene_manager := get_node("/root/SceneManager")
	
	if source_option_button.selected == 1:
		properties.message += " (PackedScene)"
		scene_manager.change_scene_to_packed(load(path), properties)
		return
	
	if loading_screen_scene_option_button.selected == 1:
		scene_manager.set_loading_screen("res://addons/scene_manager/test/custom_loading_screen/loading_screen.tscn")
	else:
		scene_manager.reset_loading_screen()
	
	if loading_screen_append_resources_check_button.button_pressed:
		properties["loaded_resources"] = [
			scene_manager.append_resource("res://addons/scene_manager/test/custom_loading_screen/loading_screen.gd"),
			scene_manager.append_resource("res://addons/scene_manager/test/change_scene/test_scene.tscn"),
		]
	
	var loading_properties := {}
	if (not loading_screen_message_line_edit.text.is_empty()):
		loading_properties["message"] = loading_screen_message_line_edit.text
	
	scene_manager.change_scene_to_file(path, properties, loading_screen_min_duration_slider.value, loading_properties)


func _on_source_selected(index: int) -> void:
	%LoadingScreenContainer.visible = index == 0


func _on_loading_screen_scene_selected(index: int) -> void:
	var message_control: Control = %LoadingScreenContainer/Controls/MessageControl
	message_control.visible = index == 1

func _on_modals_button_pressed() -> void:
	get_node("/root/SceneManager").change_scene_to_file("res://addons/scene_manager/test/modals/modals.tscn")
