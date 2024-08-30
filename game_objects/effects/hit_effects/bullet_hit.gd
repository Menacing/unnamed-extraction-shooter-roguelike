extends Node3D

@export var one_shot_emitters:Array[GPUParticles3D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for ose:GPUParticles3D in one_shot_emitters:
		ose.emitting = true

