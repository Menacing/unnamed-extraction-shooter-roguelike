extends Item3D

@export var healing_amount:float = 75

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.context_menus_use.connect(_on_context_menus_use)


func _on_context_menus_use(item_inst:ItemInstance, cursor_pos:Vector2):
	if item_inst.get_instance_id() == item_instance_id:
		EventBus.healed.emit(self._actor_id, healing_amount)
		item_inst.stacks -= 1
		if item_inst.stacks <= 0:
			InventoryManager._destroy_empty_stack(item_inst)
	pass
