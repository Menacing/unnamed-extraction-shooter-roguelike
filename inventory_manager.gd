extends Node

var stored_inventories = {}
var current_inv_controls:Array[Control] = []

func _ready():
	Events.open_inventory.connect(_on_open_inventory)
	Events.close_inventory.connect(_on_close_inventory)
	Events.create_inventory.connect(_on_create_inventory)
	
	
	
func _on_open_inventory(inventory_name:String):
	var stored_inv_node = stored_inventories[inventory_name]
	if stored_inv_node and stored_inv_node is Node:
		get_tree().get_root().add_child(stored_inv_node)
	pass
	
func _on_close_inventory(inventory_name:String):
	var inv_node:Node = stored_inventories[inventory_name]
	if inv_node:
		inv_node.get_parent().remove_child(inv_node)
		
func _on_create_inventory(inventory:Node, inventory_name:String):
	stored_inventories[inventory_name] = inventory
