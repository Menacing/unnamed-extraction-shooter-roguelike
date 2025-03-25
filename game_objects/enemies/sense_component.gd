extends Node

@export var tick_rate:float
var elapsed_time

@export var view_cone:Area3D
@export var head_node:Node3D
var exclusions:Array[RID]

#target information
var targets:Array[TargetInformation] = []

func _ready() -> void:
	if view_cone:
		view_cone.body_entered.connect(_on_body_entered_view_cone)
		view_cone.body_exited.connect(_on_body_exited_view_cone)

func _physics_process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time > tick_rate:
		elapsed_time = 0.0
		_process_senses()
		
func _process_senses():
	pass
	
func _on_body_entered_view_cone(body:Node3D):
	if body is Player:
		#var los_result = Helpers.los_to_point(head_node,body.los_check_locations,.6,exclusions,true)
		#if los_result:
		pass
		
func _on_body_exited_view_cone(body:Node3D):
	if body is Player:
		pass
