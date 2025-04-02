extends Node3D
class_name LootFiestaComponent

@export var tier:GameplayEnums.Tier
@export var loot_table:GameplayEnums.LootTable
@export var distribution:GameplayEnums.StackRandomMethod
@export var min_to_spawn:int = 0
@export var max_to_spawn:int = 1
##Only required if using Normal distribution
@export var mean_to_spawn:int = 1

func fiesta():
	#Get mapping
	var lsk:LootSpawnKey = LootSpawnKey.new()
	lsk.loot_table = loot_table
	lsk.tier = tier
	
	#Generate number to spawn
	var number_to_spawn:int
	if distribution == GameplayEnums.StackRandomMethod.RANDOM:
		number_to_spawn = randi_range(min_to_spawn, max_to_spawn)
	elif distribution == GameplayEnums.StackRandomMethod.NORMAL:
		number_to_spawn = Helpers.get_normalized_random_stack_count(min_to_spawn, mean_to_spawn, max_to_spawn)
	
	for i in number_to_spawn:
		var spawn_info:LootSpawnInformation = LootSpawnManager.get_spawn_info(lsk)
		var item_info:ItemInformation = spawn_info.item_information
		var slot_data:SlotData = SlotData.instantiate_from_item_information(item_info)
		var scene:Item3D = Item3D.instantiate_from_slot_data(slot_data)
		scene.set_as_top_level(true)		
		LevelManager.add_node_to_level.call_deferred(scene)
		scene.set_global_position.call_deferred(self.global_position)
		var random_rotation = Vector3(randf_range(0,360),randf_range(0,360),randf_range(0,360))
		scene.set_rotation_degrees.call_deferred(random_rotation)
		if scene is RigidBody3D:
			var force_magnitude:float  = randf_range(5,15)
			var x_rotation = randf_range(deg_to_rad(-30.0),deg_to_rad(30.0))
			var z_rotation = randf_range(deg_to_rad(-30.0),deg_to_rad(30.0))
			var vector_to_target = Vector3.UP.rotated(Vector3.RIGHT, x_rotation)
			vector_to_target = vector_to_target.rotated(Vector3.FORWARD, z_rotation)
			vector_to_target.normalized()
			scene.linear_velocity = vector_to_target * force_magnitude
