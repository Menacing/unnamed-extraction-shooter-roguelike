extends Control

@export var hit_indicator: PackedScene = load("res://ui/health/HitIndicator.tscn")

var hit_tween:Tween
@onready var hit_color_rect:ColorRect = %HitColorRect

func _ready():
	EventBus.took_damage.connect(_on_took_damage)

func _on_took_damage(damage:float, hit_origin:Vector3):
	var new_hit_inc:HitIndicator = hit_indicator.instantiate()
	hit_origin.y = 0
	new_hit_inc.target_pos = hit_origin
	self.add_child(new_hit_inc)
	
	var max_fade = damage / 4000.0
	var duration = damage / 800.0
	if hit_tween:
		hit_tween.kill()
	hit_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	hit_tween.tween_method(set_shader_value, 0.0, max_fade, duration) 
	hit_tween.tween_method(set_shader_value, max_fade, 0.0, duration)
	pass

func set_shader_value(value: float):
	hit_color_rect.material.set_shader_parameter("fade", value);
