extends StaticBody3D
class_name SecretHeather

var used:bool = false
var healing_amount:float = 300.0

func use(player:Player) -> void:
	if !used:
		player.main_health_component.apply_healing(healing_amount)
		used = true
		self.queue_free()
