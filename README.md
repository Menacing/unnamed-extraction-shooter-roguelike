# unnamed-extraction-shooter-roguelike
## Required Tools
* [Godot 4.4](https://godotengine.org/download/archive/4.4-stable/)
* Blender 3 or later
* Trenchbroom

## Developer Setup Instructions
1) Install Blender 3 or later
2) Install Godot 4.4
3) Open the project
4) Open Editor->Editor Settings
5) Set Blender Path to your installed Blender .exe
6) Make sure all plugins are enabled
    1) Project->Project Settings
    2) Check all Enabled checkboxes
7) Install Trenchbroom
    1) If Windows, install [Microsoft Visual C++ Redistributable for Visual Studio 2015, 2017 and 2019](https://aka.ms/vs/16/release/vc_redist.x64.exe)
8) [Set func_godot local config](https://func-godot.github.io/func_godot_docs/FuncGodot%20Manual/FuncGodot%20Manual.html)
    1) Find the trenchbroom games folder and set Fgd Output Folder to that
    2) Also set Trenchbroom Game Config Folder to that
    3) Click Export
9) Open res://levels/trenchbroom_game_config.tres and export
10) In TrenchBroom, open Preferences -> Games Tab -> Go to UESRL -> Set the game path to the "levels" folder in your local copy of the git repo
  
## Further reading
Check out the [docs](/docs/README.md) folder for more general information about how things work
