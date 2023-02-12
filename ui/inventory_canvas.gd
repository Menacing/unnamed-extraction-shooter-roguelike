extends Panel

@onready var gun_slot_1:InventorySpecialSlot = $gun_1

# Called when the node enters the scene tree for the first time.
func _ready():
	gun_slot_1.add_to_filter(ItemComponent.ItemType.GUN)
	#self.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
