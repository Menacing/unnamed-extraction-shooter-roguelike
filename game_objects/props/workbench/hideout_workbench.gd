extends Node3D

func use(player:Player) -> void:
	#toggle_inventory.emit(self)
	player.toggle_workbench.emit()
