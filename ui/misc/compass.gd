extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.compass_player_pulse.connect(_on_compass_direction_change)


func _on_compass_direction_change(player_position:Vector3, player_rotation:Vector3):
	self.text = str(Helpers.gddeg_to_compass_deg(int(round(player_rotation.y))))
