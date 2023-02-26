extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var gun_item_component = $"Node3D/AK47-Projectile/ItemComponent"

var SPEED = 3.0
var player

func _ready():
	gun_item_component.picked_up()

func _physics_process(delta):
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
	velocity = velocity.move_toward(new_velocity, .25)
	move_and_slide()
	
func update_target_location(target_location):
	nav_agent.target_position = target_location



func _on_renavigation_timer_timeout():
	if !player:
		var players = get_tree().get_nodes_in_group("players")
		player = players[0]
		
	update_target_location(player.global_transform.origin)
	
