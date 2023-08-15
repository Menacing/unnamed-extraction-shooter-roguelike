extends CharacterBody3D
class_name PlayerHitBox

@export var pen_ratio:float = 1.0
@export var damage_multiplier = 1.0
@export var location_type:HealthLocation.HEALTH_LOCATION

@onready var parent_id:int = self.owner.get_instance_id()

func _on_hit(damage, pen_rating, col:CollisionInformation, hit_origin:Vector3) -> float:
	damage = damage * damage_multiplier
	print("Took %s damage, pen rating %s at %s" % [damage, pen_rating, col.position])
	EventBus.took_damage.emit(damage, hit_origin)
	EventBus.location_hit.emit(parent_id, location_type, damage)
	return pen_ratio
