extends Control

@export var hit_indicator: PackedScene = load("res://ui/health/HitIndicator.tscn")

func _ready():
	EventBus.took_damage.connect(_on_took_damage)

func _on_took_damage(damage:float, hit_origin:Vector3):
	var new_hit_inc:HitIndicator = hit_indicator.instantiate()
	hit_origin.y = 0
	new_hit_inc.target_pos = hit_origin
	self.add_child(new_hit_inc)
	pass

