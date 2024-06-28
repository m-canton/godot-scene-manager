extends LoadingScreenBase

# Set the scene path in project settings for testing this custom loading screen.

var label_text := "Set your text!"
@onready var label: Label = $Label

func _ready() -> void:
	label.text = label_text

func _get_tween_duration() -> float:
	return 0.0 # no tween

func _get_range_object() -> Node:
	return $PanelContainer/ProgressBar
