extends Node3D

@onready var step_shape:CharacterBody3D = $CharacterBody3D
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var test_speed:float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	step_shape.velocity = Vector3(0,0,-test_speed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not step_shape.is_on_floor():
		step_shape.velocity.y -= gravity * delta
	else:
		step_shape.velocity = Vector3(0,0,-test_speed)
	step_shape.move_and_slide()
	
	
	var step_shape_velocity = step_shape.velocity.length()
	if step_shape_velocity != test_speed:
		print_debug("step shape velocity changed! : " + str(step_shape_velocity))
	
	$CharacterBody3D/IsOnFloorLabel.text = "Is On Floor: " + str(step_shape.is_on_floor())
	var step_shape_on_wall = step_shape.is_on_wall()
	$CharacterBody3D/IsOnWallLabel.text = "Is On Wall: " + str(step_shape_on_wall)
	if step_shape_on_wall:
		pass
	
	pass
