# godot-scene-manager

Scene Manager Plugin for Godot

## Features

SceneManager autoload has two methods called like global functions `change_scene_to_file` and `change_scene_to_packed_scene`. They do the same and have an optional argument `properties` to pass initial properties for next scene. You also can use a loading screen when a file path is used. You can create a custom loading screen which must extend `LoadingScreenBase` class. You can set loading screen in project settings.

Look test folder to see some examples.

## Uninstall

This plugin only has the plugin folder and "addons/scene_manager/loading_screen" project setting. You can delete both things.
