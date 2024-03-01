extends Item3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.context_menus_use.connect(_on_context_menus_use)


func _on_context_menus_use(item_inst:ItemInstance, cursor_pos:Vector2):
	pass
