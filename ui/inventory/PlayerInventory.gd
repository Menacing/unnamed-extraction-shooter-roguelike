extends BaseInventory

func _ready():
	Events.context_menu_dropped.connect(_on_context_menu_dropped)
	Events.context_menu_closed.connect(_on_context_menu_closed)
	Events.context_menu_opened.connect(_on_context_menu_opened)
	pass
	
