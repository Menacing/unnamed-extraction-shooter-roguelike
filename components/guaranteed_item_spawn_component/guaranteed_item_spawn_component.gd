extends Node3D
class_name GuaranteedItemSpawnComponent

@export var guaranteed_item_information:ItemInformation
@export var spawn_group_name:String
@export var min_number_spawned:int = 1
@export var max_number_spawned:int = 1

func _ready():
	#Call deferred because we can't be sure when ready will be called in relation to the points of interest we want to grab
	call_deferred("spawn_guaranteed_items")

func spawn_guaranteed_items():
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
					var x_size = aabb.size.x
					var z_size = aabb.size.z

					#generate random location
					spawn_pos = poi.global_position + Vector3(randf_range(-x_size,x_size),0,randf_range(-z_size,z_size))

				elif poi is Node3D:
					spawn_pos = poi.global_position
					pass
				
				if spawn_pos:
					var scene = guaranteed_item_information.item_3d_scene.instantiate()
					scene.set_as_top_level(true)		
					get_parent().add_child.call_deferred(scene)
					scene.set_global_position.call_deferred(spawn_pos)

	pass
