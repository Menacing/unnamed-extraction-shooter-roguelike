extends Node3D

@onready var step_shape:SteppingCharacterBody3D = $StaticBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	step_shape.velocity = Vector3(0,0,-5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	step_shape.move_step_and_slide(delta)
	pass
