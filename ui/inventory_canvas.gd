extends Panel

@onready var gun_slot_1:InventorySpecialSlot = $gun_1
@onready var gun_slot_2:InventorySpecialSlot = $gun_2
@onready var pockets_bag:InventoryBag = $pockets_bag
@onready var backpack_bag:InventoryBag = $backpack_bag
@onready var backpack_slot:InventorySpecialSlot = $backpack_slot

# Called when the node enters the scene tree for the first time.
func _ready():
	gun_slot_1.add_to_filter(ItemComponent.ItemType.GUN)
	gun_slot_2.add_to_filter(ItemComponent.ItemType.GUN)
	backpack_slot.add_to_filter(ItemComponent.ItemType.BACKPACK)
	
	pockets_bag.set_slot_highlight(2,0, InventoryCore.HighlightType.Disabled)
	pockets_bag.set_slot_highlight(2,1, InventoryCore.HighlightType.Disabled)
	pockets_bag.set_slot_highlight(3,0, InventoryCore.HighlightType.Disabled)
	pockets_bag.set_slot_highlight(3,1, InventoryCore.HighlightType.Disabled)
#	pockets_bag.set_slot_highlight(4,2, InventoryCore.HighlightType.Disabled)
#	pockets_bag.set_slot_highlight(4,3, InventoryCore.HighlightType.Disabled)
	#self.visible = false
	set_all_backpack_slots(InventoryCore.HighlightType.Disabled)
	
func set_all_backpack_slots(highlight:InventoryCore.HighlightType):
	for c in backpack_bag.column_count:
		for r in backpack_bag.row_count:
			backpack_bag.set_slot_highlight(c,r, highlight)
			
func set_backpack_size(size:Backpack.Size):
	match size:
		Backpack.Size.NONE:
			set_all_backpack_slots(InventoryCore.HighlightType.Disabled)
		Backpack.Size.LARGE:
			set_all_backpack_slots(InventoryCore.HighlightType.Normal)
			


func _on_gun_1_item_dropped(inv_container_event):
	pass # Replace with function body.


func _on_gun_1_item_added(inv_container_event):
	pass # Replace with function body.
