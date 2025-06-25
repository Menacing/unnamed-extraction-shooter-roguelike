extends Panel
class_name CompassBar

@onready var compass_bar:ScrollContainer = $ScrollContainer
@onready var compass_background:Control = $ScrollContainer/CompassBackground
@onready var total_scrollbar_length = $ScrollContainer/CompassBackground.size.x
@onready var pixels_per_360:int = total_scrollbar_length/4
var vertical_offset:int = 4
var flat_player_pos:Vector3
var player_pos:Vector3
var player_rotation_y:int
var _player_compass_rotation:int = 0
## Only use real american 0-360 degrees, not dumb fake communist -180 180 godot degrees. Makes the math much easier
var player_compass_rotation:int:
	get:
		return _player_compass_rotation
	set(value):
		_player_compass_rotation = value
		var new_h_s = degree_to_hscroll(value,pixels_per_360)
		compass_bar.set_h_scroll(new_h_s)
		
var extracts:Array[Node3D] = []
var obj_markers:Array[Control]

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.compass_player_pulse.connect(_on_compass_player_pulse)
	compass_bar.scroll_horizontal = pixels_per_360
	EventBus.before_previous_level_freed.connect(_on_before_previous_level_freed)
	EventBus.level_populated.connect(_on_level_populated)

func _on_before_previous_level_freed():
	for obj in obj_markers:
		obj.queue_free()
	extracts = []
	obj_markers = []
	pass
	
func _on_level_populated():
	var extract_nodes = get_tree().get_nodes_in_group("Extract")
	for node in extract_nodes:
		var textract := node as AreaExtract
		if textract and !textract.disabled and !textract.is_queued_for_deletion():
			extracts.append(textract)
		elif node is not AreaExtract:
			extracts.append(node)
	var obj_marker_scene = load("res://ui/misc/ObjectiveMarker.tscn")
	for i in extracts.size():
		var obj_marker = obj_marker_scene.instantiate()
		obj_marker.set_label(str(i+1))
		compass_background.add_child(obj_marker)
		obj_markers.append(obj_marker)
	pass


func _on_compass_player_pulse(player_position:Vector3, player_rotation:Vector3):
	flat_player_pos = player_position
	flat_player_pos.y = 0
	player_pos = player_position
	player_compass_rotation = Helpers.gddeg_to_compass_deg(int(round(player_rotation.y)))
	player_rotation_y = Helpers.gddeg_to_compass_deg(int(round(player_rotation.y)))
	recalculate_obj_marker_pos()

func recalculate_obj_marker_pos():
	for i in extracts.size():
		var extract_pos = extracts[i].global_position
		var obj_marker = obj_markers[i]
		var dir_to_obj = extract_pos - flat_player_pos
		#remove vert
		dir_to_obj.y = 0
		var deg_to_obj = angle_to_deg(Vector3.FORWARD, dir_to_obj)
		var real_deg_to_obj = Helpers.gddeg_to_compass_deg(int(round(deg_to_obj)))
		
		#if _player_compass_rotation > 270:
			#real_deg_to_obj += 360
		
		var hscroll_val = obj_degree_to_x(real_deg_to_obj, pixels_per_360, compass_bar.get_h_scroll())
		obj_marker.position.y = vertical_offset
		obj_marker.position.x = hscroll_val - obj_marker.get_rect().size.x/2
		
		if obj_marker.has_method("calculate_verticallity"):
			obj_marker.calculate_verticallity(player_pos, extract_pos)

static func angle_to_deg(source:Vector3, target:Vector3) -> int:
	var rad_result = source.signed_angle_to(target, Vector3.UP)
	var deg_result = rad_to_deg(rad_result)
	return int(round(deg_result))

## Only use real american 0-360 degrees, not dumb fake communist -180 180 godot degrees. Makes the math much easier
static func degree_to_hscroll(real_degrees:int, scroll_per_360:int) -> float:
	var new_h_s = scroll_per_360 + ((real_degrees * scroll_per_360) /  180.0)
	return new_h_s
	
static func obj_degree_to_x(real_degrees:int, scroll_per_360:int, player_h_scroll:float) -> float:
	var x = scroll_per_360 + ((real_degrees * scroll_per_360) /  180.0) + (scroll_per_360/2.0)
	
	if x  > player_h_scroll + scroll_per_360:
		x -= 2* scroll_per_360
	elif x  < player_h_scroll - scroll_per_360:
		x += 2 * scroll_per_360
		
	return x
