extends Area3D

@export var min_spawned:int
@export var max_spawned:int
@export var spawn_info:Array[LootInformation]

@onready var area:BoxShape3D = $CollisionShape3D.shape

var model_shuffle_bag:Array[LootInformation] = []
var current_shuffle_bag:Array[LootInformation] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var number_to_spawn = randi_range(min_spawned,max_spawned)
	
	var x_size = area.size.x/2.0
	var z_size = area.size.z/2.0
	
	var spawned_locations:Array[Vector3] = []
	var spawned_test_radii:Array[float] = []
	
	#generate shufflebags
	for i in range(spawn_info.size()):
		var info = spawn_info[i]
		for j in range(info.spawn_weight):
			model_shuffle_bag.append(info.duplicate())
	
	current_shuffle_bag = model_shuffle_bag.duplicate(true)
	current_shuffle_bag.shuffle()
	
	for i in range(number_to_spawn):
		var info = get_spawn_info()
		
		var final_pos:Vector3
		var remaining_tries = 5
		while remaining_tries > 1:
			#generate random location
			var try_pos = Vector3(randf_range(-x_size,x_size),0,randf_range(-z_size,z_size))
			var loc_free = true
			for k in range(spawned_locations.size()):
				#check if location overlaps existing location
				if abs((spawned_locations[k] - try_pos).length()) < info.test_radius:
					loc_free = false
			#if clear, spawn scene
			if loc_free:
				var scene = info.scene.instantiate()
				var ic = scene.get_node("ItemComponent") as ItemComponent
				
				if info.max_stack > 0:
					var stack:int = randi_range(info.min_stack, info.max_stack)
					ic.stack = stack
				
				#scene.set_as_top_level(true)
				get_parent().add_child.call_deferred(scene)
				scene.global_position = try_pos + self.global_position
				spawned_locations.append(try_pos)
				remaining_tries = 0
				ic.dropped()
			else:
				remaining_tries -= 1


func get_spawn_info():
	if current_shuffle_bag.is_empty():
		current_shuffle_bag = model_shuffle_bag.duplicate(true)
		current_shuffle_bag.shuffle()
	
	return current_shuffle_bag.pop_front()