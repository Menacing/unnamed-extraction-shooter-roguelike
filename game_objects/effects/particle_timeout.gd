extends Node3D

@onready var timer:Timer = $Timer

func _on_timer_timeout():
	self.queue_free()
