extends Label

func _ready():
	Events.fire_mode_changed.connect(_on_firetype_change)


func _on_firetype_change(fire_type:String):
	self.text = fire_type
