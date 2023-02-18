extends Node

#signal inventory_closed(player:Player)
signal item_equipped(slot_name:String, item_equipped:ItemComponent)
signal item_removed(slot_name:String, item_removed:ItemComponent)
signal item_dropped(item_dropped:ItemComponent)
signal item_picked_up(item_picked_up:ItemComponent)
