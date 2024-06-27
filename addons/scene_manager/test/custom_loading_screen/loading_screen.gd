extends LoadingScreenBase

# Set the scene path in project settings for testing this custom loading screen.

func _get_range_node() -> Node:
	return $PanelContainer/ProgressBar
