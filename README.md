# godot-scene-manager

Scene Manager Plugin for Godot 4.1+.

## Features

SceneManager autoload has three methods called `change_scene_to_file`, `change_scene_to_packed` and `reload_current_scene` like SceneTree methods. They do the same and have an optional argument `properties` to pass initial properties for next scene. You also can use a loading screen when a file path is used. You can create a custom loading screen which must extend `LoadingScreenBase` class. You can set loading screen in project settings.

See [test folder](https://github.com/m-canton/godot-scene-manager/tree/main/addons/scene_manager/test) and [wiki](https://github.com/m-canton/godot-scene-manager/wiki) for some examples. Simple use:

```gdscript
var ref := SceneManager.append_resource("my_character_data.tres")
SceneManager.change_scene_to_file("my_scene.tscn", {
    next_scene_characters_property = [
        ref,
    ],
}, 1.0, {
    a_loading_screen_property = "Other value",
})
```

## Install

You can download this plugin from Godot Asset Library. Here you can find the last changes. You can use it, adding `scene_manager` folder in your project addons folder and enabling this plugin. `test` folder contains examples, you can remove it.

## Uninstall

This plugin only has the plugin folder and "addons/scene_manager/loading_screen" project setting. You can delete both things.
