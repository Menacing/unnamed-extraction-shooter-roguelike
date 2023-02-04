extends RigidBody3D

@export var initial_speed = 700.0
@export var initial_damage = 30.0
@export var imperial_ballistic_coefficient = 0.27
@export var bullet_mass_grams = 8.0
@export var bullet_diameter_mm = 7.85

var current_speed: float
var current_damage: float

var air_density = 1.2
var bullet_area_meter_sq
var bullet_diameter_meter
var metric_ballistic_coefficient
var bullet_mass_kg
var drag_coefficient
var k

# Called when the node enters the scene tree for the first time.
func _ready():
	current_speed = initial_speed
	current_damage = initial_damage
	connect("body_entered", _on_body_entered)
	bullet_diameter_meter = bullet_diameter_mm / 1000.0
	bullet_area_meter_sq = PI * bullet_diameter_meter * bullet_diameter_meter / 4.0
	metric_ballistic_coefficient = imperial_ballistic_coefficient * 703.0
	bullet_mass_kg = bullet_mass_grams / 1000.0
	drag_coefficient = 0.5191 * bullet_mass_kg / metric_ballistic_coefficient / bullet_diameter_meter / bullet_diameter_meter
	k = .5 / bullet_mass_kg * air_density * drag_coefficient * bullet_area_meter_sq

func _physics_process(delta):
#	global_translate(-delta * current_speed * transform.basis.z)
	var col = move_and_collide(-delta * current_speed * transform.basis.z,false,0.001,true)
	if col:
		print(col)
		queue_free()
	var new_speed = (current_speed/ (1+k*delta*current_speed))
	current_damage = pow(new_speed/current_speed,2) * current_damage
	if current_damage < 1:
		print("bullet peetered out")
		queue_free()


func _on_body_entered(body):
	print(body)
	queue_free() 
