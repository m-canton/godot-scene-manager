# godot-scene-manager

Scene Manager Plugin for Godot 4.2+.

## Features

SceneManager autoload has three methods called `change_scene_to_file`, `change_scene_to_packed` and `reload_current_scene` like SceneTree methods. They do the same and have an optional argument `properties` to pass initial properties for next scene. You also can use a loading screen when a file path is used. You can create a custom loading screen which must extend `LoadingScreenBase` class. You can set loading screen in project settings.

Check [test folder](https://github.com/m-canton/godot-scene-manager/tree/main/addons/scene_manager/test) and [wiki](https://github.com/m-canton/godot-scene-manager/wiki) to see examples about [transitions](https://github.com/m-canton/godot-scene-manager/wiki/Transitions), [opening/closing modals](https://github.com/m-canton/godot-scene-manager/wiki/Modals) and more! Basic example:

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

You can download this plugin from Godot Asset Library. Here you can find the last changes. Download and set `addons/scene_manager` folder in your project and enable the plugin in Project Settings. `test` folder contains examples, you can remove it.

When you enable this plugin, the `SceneManager` autoload and `addons/scene_manager/*` project settings are added. Also an EditorExportPlugin is added to remove test files in your exported project. If you disable the plugin, the autoload and export plugin are removed but settings values keep. This is to remember your custom settings. If you want to delete the plugin, you must manually remove the custom settings.

## Uninstall

- Disable the plugin (remove an autoload and an EditorExportPlugin).
- Remove `scene_manager` from addons folder.
- Manually remove the `addons/scene_manager/*` project settings.
