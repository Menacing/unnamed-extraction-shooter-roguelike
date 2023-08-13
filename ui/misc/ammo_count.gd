extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.ammo_count_changed.connect(_on_ammo_count_change)


func _on_ammo_count_change(new_count:int):
	self.text = str(new_count)
