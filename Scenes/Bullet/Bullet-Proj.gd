extends RigidBody3D

@export var initial_speed = 700.0
@export var initial_damage = 30.0
@export var pen_rating: int = 5
@export var k: float = 0.001289

var current_speed: float
var current_damage: float
var elapsed_time: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	current_speed = initial_speed
	current_damage = initial_damage
#	connect("body_entered", _on_body_entered)

func _physics_process(delta):
#	global_translate(-delta * current_speed * transform.basis.z)
	elapsed_time += delta
	var col = move_and_collide(-delta * current_speed * transform.basis.z,false,0.001,true)
	#If we collide, get the collider and see if it can be hit or if it can be penetrated
	if col:
		print(col)
		var collider = col.get_collider()
		if collider and collider.has_method("_on_hit"):
			var pen_ratio = collider._on_hit(current_damage, pen_rating, col.get_position(), col.get_normal())
			var new_speed = current_speed * pen_ratio
			current_damage = pow(new_speed/current_speed,2) * current_damage
			current_speed = new_speed
			self.add_collision_exception_with(collider)
		else:
			queue_free()
	var new_speed = (current_speed/ (1+k*delta*current_speed))
	current_damage = pow(new_speed/current_speed,2) * current_damage
	current_speed = new_speed
	if is_nan(current_damage) or current_damage / initial_damage < .25:
		print("bullet peetered out after %s" % elapsed_time)
		queue_free()

#func _on_body_entered(body):
#	print(body)
#	queue_free() 
