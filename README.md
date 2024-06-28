# godot-scene-manager

Scene Manager Plugin for Godot 4.3

## Features

SceneManager autoload has three methods called `change_scene_to_file`, `change_scene_to_packed_scene` and `reload_current_scene` like SceneTree methods. They do the same and have an optional argument `properties` to pass initial properties for next scene. You also can use a loading screen when a file path is used. You can create a custom loading screen which must extend `LoadingScreenBase` class. You can set loading screen in project settings.

Look [test folder](https://github.com/m-canton/godot-scene-manager/tree/main/addons/scene_manager/test) and [wiki](https://github.com/m-canton/godot-scene-manager/wiki) to see some examples. Simple use:

```gdscript
SceneManager.change_scene_to_file("your_tscn_file_path", {
    my_next_scene_property = "A value",
}, 1.0)
```

## Install

You can download this plugin from Godot Asset Library. Here you can find the last changes. You can use it, adding scene_manager folder in your project addons folder and enabling this plugin.

## Uninstall

This plugin only has the plugin folder and "addons/scene_manager/loading_screen" project setting. You can delete both things.
