@tool
extends EditorPlugin


func _enable_plugin() -> void:
	add_autoload_singleton("SceneManager", "res://addons/scene_manager/autoload/scene_manager.gd")


func _disable_plugin() -> void:
	remove_autoload_singleton("SceneManager")


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
