extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var head = $Head as Node3D
@export var health:float = 100.0
var run_speed = 3
var accel = 3
var alive = true
@onready var armor = $light_armor_1


# Called when the node enters the scene tree for the first time.
func _ready():
	armor.get_node("ItemComponent").picked_up()
	pass


func _on_took_damage(damage:float):
	health-=damage
	if health < 0:
		die()
		
func die():
	print("I am dead")
	alive = false

@export var pen_ratio:float = 1.0
@export var damage_multiplier = 1.0

func _on_hit(damage, pen_rating, col:CollisionInformation, hit_origin:Vector3) -> float:
	damage = damage * damage_multiplier
	print("Took %s damage, pen rating %s at %s" % [damage, pen_rating, col.position])
	_on_took_damage(damage)
	return pen_ratio
