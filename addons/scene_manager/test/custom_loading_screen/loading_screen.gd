extends LoadingScreen

# Set the scene path in project settings for testing this custom loading screen.

var message := "Set your text!"
@onready var label: Label = $Label

func _ready() -> void:
	label.text = message

func _get_tween_duration() -> float:
	return 0.0 # no tween

func _get_range_object() -> Object:
	return $PanelContainer/ProgressBar
