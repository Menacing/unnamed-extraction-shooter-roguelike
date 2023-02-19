extends Node

signal player_inventory_closed(player:Player)
signal item_equipped(slot_name:String, item_equipped:ItemComponent)
signal item_removed(slot_name:String, item_removed:ItemComponent)
signal item_dropped(item_dropped:ItemComponent)
signal item_picked_up(item_picked_up:ItemComponent)


signal close_inventory(inventory_name:String)
signal open_inventory(inventory_name:String)
signal create_inventory(inventory:Node, inventory_name:String)
