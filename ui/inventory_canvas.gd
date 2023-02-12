extends Panel

@onready var gun_slot_1:InventorySpecialSlot = $gun_1
@onready var gun_slot_2:InventorySpecialSlot = $gun_2
@onready var pockets_bag:InventoryBag = $pockets_bag

# Called when the node enters the scene tree for the first time.
func _ready():
	gun_slot_1.add_to_filter(ItemComponent.ItemType.GUN)
	gun_slot_2.add_to_filter(ItemComponent.ItemType.GUN)
	
	pockets_bag.set_slot_highlight(2,0, InventoryCore.HighlightType.Disabled)
	pockets_bag.set_slot_highlight(2,1, InventoryCore.HighlightType.Disabled)
#	pockets_bag.set_slot_highlight(4,2, InventoryCore.HighlightType.Disabled)
#	pockets_bag.set_slot_highlight(4,3, InventoryCore.HighlightType.Disabled)
	#self.visible = false
