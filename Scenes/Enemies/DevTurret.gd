extends CharacterBody3D

@onready var head = $Head as Node3D
@export var gun_scene: PackedScene
var gun: Gun
var hf_pos: Vector3
@export var health:float = 100.0

# Called when the node enters the scene tree for the first time.
func _ready():
	gun = gun_scene.instantiate()
	var gun_item_comp:ItemComponent = gun.get_node("ItemComponent")
	gun_item_comp.start_highlighted = false
	gun_item_comp.picked_up()
	#TODO: Pull these from the packed scene instead of being hardcoded
	gun.magazineSize = 30000
	gun.magazine= 30000
	hf_pos = -gun.get_node("HipFire").position

	gun.position = hf_pos
	head.add_child(gun)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_fire_timer_timeout():
	gun.fireGun()

func _on_took_damage(damage:float):
	health-=damage
	if health < 0:
		print("I am dead")
		queue_free()

@export var pen_ratio:float = 1.0
@export var damage_multiplier = 1.0

func _on_hit(damage = 0.0, pen_rating = 0, col:KinematicCollision3D = null) -> float:
	damage = damage * damage_multiplier
	print("Took %s damage, pen rating %s at %s" % [damage, pen_rating, col.get_position()])
	_on_took_damage(damage)
	return pen_ratio
