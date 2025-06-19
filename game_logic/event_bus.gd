extends Node

#Hideout Events
signal material_changed(crafting_material_entry:CraftingMaterialEntry)

#Misc Events
signal use_helper_visibility(show:bool)
signal pickup_helper_visibility(show:bool, display_text:String)
signal magazine_ammo_count_changed(new_count:int)
signal active_reserve_ammo_count_changed(new_count:int)
signal reserve_ammo_count_changed(ammo_type:String, ammo_subtype:String, new_amount:int)
signal ammo_type_changed(new_type:String, new_subtype:String)
signal fire_mode_changed(new_firemode:String)
signal compass_player_pulse(player_position:Vector3, player_rotation:Vector3)
signal drop_ammo(actor_id:int, type:String, subtype:String, amount:int)
signal drop_all_ammo(actor_id:int, type:String, subtype:String)


#save/load lifecycle
signal before_level_loading
signal before_previous_level_freed
signal before_populate_level
signal populate_level
signal level_populated
signal player_spawning
signal players_spawned
signal game_saving(save_file:SaveFile)
signal game_saved
signal before_game_loading
signal game_loading
signal game_loaded
signal level_loaded

#UI Events
signal pause()
signal create_message(message_name:String, message_text:String, message_timeout:float)
signal update_message(message_name:String, message_text:String)
signal remove_message(message_name:String)
signal create_effect(actor_id:int, gameplay_effect:GameplayEffect)
signal remove_effect(actor_id:int, gameplay_effect:GameplayEffect)

#Navigation Events
signal navigation_mesh_list_item_baked(nmli:NavigationMeshListItem)

signal sound_emitted(source:Node, global_position:Vector3, audible_distance:float)
