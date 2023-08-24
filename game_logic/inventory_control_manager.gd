extends Node

var stored_inventories = {}
var ui_node:CanvasLayer
@export var inventory_ui_layer:NodePath = "Main/PlayerHUD"

func _ready():
	EventBus.open_inventory.connect(_on_open_inventory)
	EventBus.close_inventory.connect(_on_close_inventory)
	EventBus.create_inventory.connect(_on_create_inventory)

func get_inventory(inv_name:String):
	if stored_inventories.has(inv_name):
		return stored_inventories[inv_name]
	else:
		return null

func _on_open_inventory(inventory_name:String):
	ui_node = get_tree().get_root().get_node(inventory_ui_layer)
	var stored_inv_node = stored_inventories[inventory_name]
	if stored_inv_node and stored_inv_node is Node:
		ui_node.add_child(stored_inv_node)
	pass

func _on_close_inventory(inventory_name:String):
	var inv_node:Node = stored_inventories[inventory_name]
	if inv_node:
		inv_node.get_parent().remove_child(inv_node)

func _on_create_inventory(inventory:Node, inventory_name:String):
	stored_inventories[inventory_name] = inventory
