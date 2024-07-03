extends Control


var message := ""

@onready var source_option_button: OptionButton = %ChageSceneContainer/Controls/SourceControl/OptionButton
@onready var message_line_edit: LineEdit = %ChageSceneContainer/Controls/MessageControl/LineEdit

@onready var loading_screen_scene_option_button: OptionButton = %LoadingScreenContainer/Controls/SceneControl/OptionButton
@onready var loading_screen_min_duration_slider: HSlider = %LoadingScreenContainer/Controls/MinDurationControl/HSlider
@onready var loading_screen_message_line_edit: LineEdit = %LoadingScreenContainer/Controls/MessageControl/LineEdit
@onready var loading_screen_append_resources_check_button: CheckButton = $ColorRect/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer/LoadingScreenContainer/AppendResourcesControl/CheckButton

@onready var change_scene_button: Button = $ColorRect/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer/ChangeSceneButton

@onready var message_label = $ColorRect/VBoxContainer/MessageMarginContainer/MessageLabel

func _ready() -> void:
	message_label.text = message
	
	_on_source_selected(source_option_button.selected)
	source_option_button.item_selected.connect(_on_source_selected)
	
	_on_loading_screen_scene_selected(loading_screen_scene_option_button.selected)
	loading_screen_scene_option_button.item_selected.connect(_on_loading_screen_scene_selected)
	
	change_scene_button.pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	var path := "res://addons/scene_manager/test/change_scene/other_scene.tscn"
	
	var properties := { message = message_line_edit.text }
	
	if source_option_button.selected == 1:
		properties.message += " (PackedScene)"
		get_node("/root/SceneManager").change_scene_to_packed(load(path), properties)
		return
	
	if loading_screen_scene_option_button.selected == 1:
		get_node("/root/SceneManager").set_loading_screen("res://addons/scene_manager/test/custom_loading_screen/loading_screen.tscn", get_node("/root/SceneManager").LoadingScreenType.PERSIST)
	else:
		get_node("/root/SceneManager").reset_loading_screen()
	
	if loading_screen_append_resources_check_button.button_pressed:
		properties["loading_dependency"] = [
			get_node("/root/SceneManager").append_resource("res://addons/scene_manager/test/custom_loading_screen/loading_screen.gd"),
			get_node("/root/SceneManager").append_resource("res://addons/scene_manager/test/change_scene/test_scene.tscn"),
		]
	
	var loading_properties := {}
	if (not loading_screen_message_line_edit.text.is_empty()):
		loading_properties["message"] = loading_screen_message_line_edit.text
	
	get_node("/root/SceneManager").change_scene_to_file(path, properties, loading_screen_min_duration_slider.value, loading_properties)


func _on_source_selected(index: int) -> void:
	%LoadingScreenContainer.visible = index == 0


func _on_loading_screen_scene_selected(index: int) -> void:
	var message_control: Control = %LoadingScreenContainer/Controls/MessageControl
	message_control.visible = index == 1
