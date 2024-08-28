extends Area3D
class_name HurtBoxComponent

@export var pen_ratio:float = 1.0
@export var damage_multiplier = 1.0
@export var health_location:HealthComponent



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func hit(damage_component:DamageComponent) -> DamageResult:
	var damage = damage_component.damage * damage_multiplier
	health_location.apply_damage(damage)
	return DamageResult.new(pen_ratio)


func _on_body_entered(body):
	if body and body is DamageComponent:
		hit(body)
		pass
	pass # Replace with function body.

