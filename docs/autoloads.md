## Auto Loads
### [EventBus](../game_logic/event_bus.gd)
Class for propegating game events without needing to tightly couple nodes with each other. If something happened that other areas of the game need to know about, throw it on the bus.

### [GameSettings](../game_logic/game_settings.gd)
Singleton to hold common gameplay settings. If there's a preference type thing related to gameplay, throw it here

### [Helpers](../helpers/helpers.gd)
Singleton for a bunch of common functions to help out. If you're writing a lot of boilerplate code to accomplish something over and over, consider throwing it in a function and putting it here.

### [MenuManager](../game_logic/menu_manager.gd)
Singlton for managing showing and hiding game menus, such as the pause and options menu. Inventory is part of gameplay and considered part of the HUD and handled elsewhere

### [GameplayEnums](../game_logic/gameplay_enums.gd)
Singleton to hold enums so we don't have to remember which class each enum is attached to. GD Script doesn't allow global scope easily

### [GGS](../addons/ggs/classes/global/ggs.tscn)
Singleton for the Godot Game Settings addon. Probably don't need to modify directly

### [SaveManager](../game_logic/save_manager.gd)
Singleton to handle saving and loading game save data

### [ItemMappingRepository](../game_logic/item_mapping_repository.gd)]
Singleton to load app ItemMappings to tie ItemInformation, SlotData, and Item3D together without creating a circular dependency

### [AmmoLoader](../components/ammo_component/ammo_loader.gd)
Singleton that crawls the file system and loads up a mapping of every ammo type

### [EnemySpawnManager](../game_logic/enemy_spawn_manager.gd)
Singleton holds each biome's spawn mapping for use by spawn areas

### [LootSpawnManager](../game_logic/loot_spawn_manager.gd)
Same, but for loot spawn areas

### [GameplayEffectManager](../game_logic/gameplay_effect_manager.gd)
Singleton for registering new gameplay effects.

### [UiSounds](../game_logic/ui_sounds.gd)
Adds sounds to menus

### [LevelManager](../game_logic/level_manager.gd)
Handles loading and unloading levels and adding new objects to the stage

### [HideoutManager](../game_logic/hideout_manager.gd)
Handles upgrades, stash, and materials for a run along with run level information