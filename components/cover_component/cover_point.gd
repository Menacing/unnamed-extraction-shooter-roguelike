extends Marker3D
class_name CoverPoint

var _low_los:bool = true
var is_low_cover:bool:
	get:
		return !_low_los and _high_los

var _high_los:bool = true
var is_high_cover:bool:
	get:
		return !_low_los and !_high_los


var _process_delay:float = 1.0

var elapsed_time:float = 0.0

var _offset_origin:Vector3

func _ready() -> void:
	_offset_origin = self.global_position + (Vector3.UP * 1.5)
	_process_delay + randf_range(-0.5, 0.5)
	
func _physics_process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time > _process_delay:
		elapsed_time = 0.0
		update_cover_state()

func update_cover_state():
	_low_los = false
	_high_los = false
	
	var players = get_tree().get_nodes_in_group("players")
	
	for player:Player in players:
		var space_state = get_world_3d().direct_space_state
		
		#low check
		var start = global_position
		var end = player.global_position
		var low_query = PhysicsRayQueryParameters3D.create(start, end)
		low_query.exclude = player.self_exclusions
		low_query.collision_mask = 0b00000000_00000000_00000000_00000010
		var low_hit = space_state.intersect_ray(low_query)
		
		if !low_hit:
			_low_los = true

		var high_query = PhysicsRayQueryParameters3D.create(_offset_origin, end)
		high_query.exclude = player.self_exclusions
		high_query.collision_mask = 0b00000000_00000000_00000000_00000010
		var high_hit = space_state.intersect_ray(high_query)
		
		if !high_hit:
			_high_los = true
		
