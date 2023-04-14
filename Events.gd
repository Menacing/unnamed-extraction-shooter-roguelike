extends Node

#Inventory Events
signal player_inventory_visibility(show:bool)
signal player_inventory_closed(player:Player)
signal player_inventory_try_pickup(item_component:ItemComponent)
signal item_equipped(slot_name:String, item_equipped:ItemComponent)
signal item_removed(slot_name:String, item_removed:ItemComponent)
signal item_dropped(item_dropped:ItemComponent)
signal item_picked_up(item_picked_up:ItemComponent)
signal item_destroyed(item_comp:ItemComponent)
signal context_menu_dropped(iib:InvItemBase, pos:Vector2)
signal context_menu_opened()
signal context_menu_closed()

signal close_inventory(inventory_name:String)
signal open_inventory(inventory_name:String)
signal create_inventory(inventory:Node, inventory_name:String)

#Health Events
signal took_damage(damage:float, hit_origin:Vector3)
signal player_health_pulse(health:Array[HealthLocation])
signal health_changed(actor_id:int, location:HealthLocation.HEALTH_LOCATION, \
	current_health:float, max_health:float)
signal location_hit(actor_id:int, location:HealthLocation.HEALTH_LOCATION, \
	damage:float)
signal location_healed(actor_id:int, location:HealthLocation.HEALTH_LOCATION, \
	healed:float)
signal location_destroyed(actor_id:int, location:HealthLocation.HEALTH_LOCATION)
signal location_restored(actor_id:int, location:HealthLocation.HEALTH_LOCATION)

#Misc Events
signal use_helper_visibility(show:bool)
signal pickup_helper_visibility(show:bool)
signal ammo_count_changed(new_count:int)
signal fire_mode_changed(new_firemode:String)
signal compass_player_pulse(player_position:Vector3, player_rotation:Vector3)

#UI Events
signal pause()
