@tool
extends EditorPlugin

var _export_plugin: EditorExportPlugin

func _enter_tree() -> void:
	add_autoload_singleton("SceneManager", "res://addons/scene_manager/autoload/scene_manager.gd")
	
	# Removes files from test and editor folders.
	_export_plugin = preload("res://addons/scene_manager/editor/export.gd").new()
	add_export_plugin(_export_plugin)


func _exit_tree() -> void:
	remove_autoload_singleton("SceneManager")
	
	remove_export_plugin(_export_plugin)
	_export_plugin = null
