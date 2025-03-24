@tool
class_name StashContainer
extends GeoBallisticSolid

enum StashSize {
	SMALL = 4,
	MEDIUM = 8,
	LARGE = 16
}

@onready var item_highlight_m:ShaderMaterial = load("res://themes/item_highlighter_m.tres")

@onready var small_stash_2: Node3D = $small_stash2
@onready var small_stash_collision_shape_3d: CollisionShape3D = $SmallStashCollisionShape3D


@onready var medium_stash_2: Node3D = $medium_stash2
@onready var medium_stash_collision_shape_3d: CollisionShape3D = $MediumStashCollisionShape3D


signal toggle_inventory(external_inventory_owner)

@export var inventory_data:InventoryData

func use(player:Player) -> void:
	#toggle_inventory.emit(self)
	player.toggle_stash.emit()


func _ready():
	inventory_data.inventory_size_changed.connect(_on_stash_size_changed)
	inventory_data.set_inventory_size(HideoutManager.current_stash_size)
	HideoutManager.inventory_data = inventory_data
	

func _on_stash_size_changed(inv_data:InventoryData, new_size:int) -> void:
	match new_size:
		StashSize.SMALL:
			small_stash_2.visible = true
			small_stash_collision_shape_3d.disabled = false
			
			medium_stash_2.visible = false
			medium_stash_collision_shape_3d.disabled = true
		StashSize.MEDIUM:
			small_stash_2.visible = false
			small_stash_collision_shape_3d.disabled = true
			
			medium_stash_2.visible = true
			medium_stash_collision_shape_3d.disabled = false
		StashSize.LARGE:
			pass
		_:
			printerr("Setting stash to invalide size")
	pass
