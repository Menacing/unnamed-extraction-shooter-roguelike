extends Node3D

@onready var step_shape:SteppingCharacterBody3D = $StaticBody3D
@onready var cb3d:CharacterBody3D = $CharacterBody3D

var test_speed:float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	step_shape.velocity = Vector3(0,0,-test_speed)
	cb3d.velocity = Vector3(0,0,-test_speed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#step_shape.velocity = Vector3(0,0,-test_speed)
	#cb3d.velocity = Vector3(0,0,-test_speed)
	step_shape.move_step_and_slide(delta)
	$StaticBody3D/IsOnFloorLabel.text = "Is On Floor: " + str(step_shape.is_on_floor())
	$StaticBody3D/IsOnWallLabel.text = "Is On Wall: " + str(step_shape.is_on_floor())
	
	cb3d.move_and_slide()
	$CharacterBody3D/IsOnFloorLabel.text = "Is On Floor: " + str(cb3d.is_on_floor())
	$CharacterBody3D/IsOnWallLabel.text = "Is On Wall: " + str(cb3d.is_on_floor())
	
	
	pass