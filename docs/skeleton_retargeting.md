# Skeleton Retargeting
Skeleton retargeting is the process of taking animations intended for one model and mapping them onto another. This way we don't need special animations for each model and can share assets where it makes sense.

1) Acquire a file with animations in it
2) Open the import tab and switch to Import As Animation Library
3) Open the Advanced Import menu in Godot
4) Follow the [Godot Guide](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/retargeting_3d_skeletons.html)
   1) You can use the [existing](../game_objects/enemies/humanoid_bone_map.tres) bone map
5) Import the resulting animations to your `AnimationPlayer` as a library
