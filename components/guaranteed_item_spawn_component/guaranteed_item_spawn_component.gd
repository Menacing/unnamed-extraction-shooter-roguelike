extends Node3D
class_name GuaranteedItemSpawnComponent

@export var guaranteed_item_information:ItemInformation
@export var spawn_group_name:String
@export var min_number_spawned:int = 1
@export var max_number_spawned:int = 1

func _ready():
	EventBus.populate_level.connect(_on_populate_level)
		
func _on_populate_level():
	#only run if we have item info, a group name, and a min greater than 0
	if guaranteed_item_information and spawn_group_name and min_number_spawned >= 0 and max_number_spawned >= min_number_spawned:
		#get number to spawn and nodes in spawn group. Shuffle nodes
		var number_to_spawn := randi_range(min_number_spawned, max_number_spawned)
		var pois = get_tree().get_nodes_in_group(spawn_group_name)
		pois.shuffle()

		#for each item to spawn, grab a poi
		for i in range(number_to_spawn):
			var poi = pois.pop_front()
			if poi:
				#if poi is area3d, find place to spawn item
				var spawn_pos:Vector3
				if poi is Area3D:
					var aabb = Helpers.get_aabb_of_node(poi)
					var x_begin = aabb.position.x
					var x_end = aabb.end.x
					var z_begin = aabb.position.z
					var z_end = aabb.end.z

					#generate random location
					spawn_pos = poi.global_position + Vector3(randf_range(x_begin,x_end),0,randf_range(z_begin,z_end))

				elif poi is Node3D:
					spawn_pos = poi.global_position
					pass
				
				if spawn_pos:
					var scene = guaranteed_item_information.item_3d_scene.instantiate()
					scene.set_as_top_level(true)		
					get_parent().add_child.call_deferred(scene)
					scene.set_global_position.call_deferred(spawn_pos)

	pass
