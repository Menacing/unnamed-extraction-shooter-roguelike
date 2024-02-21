extends Node3D

@export_node_path("CollisionShape3D") var separation_ray_path_front
@export_node_path("CollisionShape3D") var separation_ray_path_front_right
@export_node_path("CollisionShape3D") var separation_ray_path_right
@export_node_path("CollisionShape3D") var separation_ray_path_back_right
@export_node_path("CollisionShape3D") var separation_ray_path_back
@export_node_path("CollisionShape3D") var separation_ray_path_back_left
@export_node_path("CollisionShape3D") var separation_ray_path_left
@export_node_path("CollisionShape3D") var separation_ray_path_front_left

@export_node_path("ShapeCast3D") var headroom_shapecast_path
@onready var separation_ray_front:CollisionShape3D = get_node(separation_ray_path_front)
@onready var separation_ray_front_right:CollisionShape3D = get_node(separation_ray_path_front_right)
@onready var separation_ray_right:CollisionShape3D = get_node(separation_ray_path_right)
@onready var separation_ray_back_right:CollisionShape3D = get_node(separation_ray_path_back_right)
@onready var separation_ray_back:CollisionShape3D = get_node(separation_ray_path_back)
@onready var separation_ray_back_left:CollisionShape3D = get_node(separation_ray_path_back_left)
@onready var separation_ray_left:CollisionShape3D = get_node(separation_ray_path_left)
@onready var separation_ray_front_left:CollisionShape3D = get_node(separation_ray_path_front_left)
@onready var headroom_ray:ShapeCast3D = get_node(headroom_shapecast_path)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var headroom_ray_is_colliding = headroom_ray.is_colliding()
	separation_ray_front.disabled = headroom_ray_is_colliding
	separation_ray_front_right.disabled = headroom_ray_is_colliding
	separation_ray_right.disabled = headroom_ray_is_colliding
	separation_ray_back_right.disabled = headroom_ray_is_colliding
	separation_ray_back.disabled = headroom_ray_is_colliding
	separation_ray_back_left.disabled = headroom_ray_is_colliding
	separation_ray_left.disabled = headroom_ray_is_colliding
	separation_ray_front_left.disabled = headroom_ray_is_colliding
	pass
