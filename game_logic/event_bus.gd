extends Node



#Inventory Events
signal add_inventory(inventory:Inventory)
signal pickup_item(item_inst:ItemInstance, target_inventory_id:int)
signal drop_item(item_inst:ItemInstance, inventory_id:int)
signal item_picked_up(result:InventoryInsertResult)
signal item_removed_from_inventory(item_inst:ItemInstance, inventory_id:int)
signal item_removed_from_slot(item_inst:ItemInstance, inventory_id:int, slot_name:String)
signal item_stack_count_changed(item_inst:ItemInstance)
signal item_durability_changed(item_inst:ItemInstance)
signal close_inventory(inventory_id:int)
signal close_all_inventories()
signal open_inventory(inventory_id:int)

#Inventory Control Events
signal add_inventory_to_HUD(inventory_control:InventoryControlBase)
signal remove_inventory_from_HUD(inventory_control:InventoryControlBase, new_parent:Node)
signal inventory_size_changed(inventory_id:int, size:Vector2i)
signal context_menu_opened()
signal context_menu_closed()
signal context_menus_use(item_inst:ItemInstance, cursor_pos:Vector2)
signal context_menus_drop_item(item_inst:ItemInstance, cursor_pos:Vector2)
signal context_menus_split_stack(item_inst:ItemInstance, cursor_pos:Vector2)
signal context_menus_open_item_detail(item_inst:ItemInstance, cursor_pos:Vector2)
signal item_control_quick_transfer(item_control:ItemControl)

#Health Events
signal took_damage(damage:float, hit_origin:Vector3)
signal health_changed(actor_id:int, location:HealthLocation.HEALTH_LOCATION, \
	current_health:float, max_health:float)
signal location_hit(actor_id:int, location:HealthLocation.HEALTH_LOCATION, \
	damage:float)
signal healed(actor_id:int, healed:float)
signal location_healed(actor_id:int, location:HealthLocation.HEALTH_LOCATION, \
	healed:float)
signal location_destroyed(actor_id:int, location:HealthLocation.HEALTH_LOCATION)
signal location_restored(actor_id:int, location:HealthLocation.HEALTH_LOCATION)

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
