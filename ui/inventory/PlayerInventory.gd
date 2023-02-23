extends BaseInventory

func _ready():
	Events.player_inventory_visibility.connect(_on_player_inventory_visibility)
	Events.context_menu_dropped.connect(_on_context_menu_dropped)
	Events.context_menu_closed.connect(_on_context_menu_closed)
	Events.context_menu_opened.connect(_on_context_menu_opened)
	Events.player_inventory_try_pickup.connect(_on_player_inventory_try_pickup)
	pass
	
func _on_player_inventory_visibility(show:bool):
	self.visible = show
	
func _on_player_inventory_try_pickup(item_comp:ItemComponent):
	pickup_item(item_comp)
