extends Panel
class_name CompassBar

@onready var compass_bar:ScrollContainer = $ScrollContainer
@onready var compass_background:Control = $ScrollContainer/CompassBackground
@onready var total_scrollbar_length = $ScrollContainer/CompassBackground.size.x
@onready var pixels_per_360:int = total_scrollbar_length/4
var vertical_offset:int = 4
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
		
var extracts:Array
var obj_markers:Array[Control]

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.compass_player_pulse.connect(_on_compass_player_pulse)
	compass_bar.scroll_horizontal = pixels_per_360
	var extract_nodes = get_tree().get_nodes_in_group("Extract")
	extracts = extract_nodes
	var obj_marker_scene = load("res://ui/misc/ObjectiveMarker.tscn")
	for i in extracts.size():
		var obj_marker = obj_marker_scene.instantiate()
		var obj_label = obj_marker.get_node("Label")
		obj_label.text = str(i+1)
		compass_background.add_child(obj_marker)
		obj_markers.append(obj_marker)

func _on_compass_player_pulse(player_position:Vector3, player_rotation:Vector3):
	player_pos = player_position
	player_pos.y = 0
	player_compass_rotation = Helpers.gddeg_to_compass_deg(int(round(player_rotation.y)))
	player_rotation_y = Helpers.gddeg_to_compass_deg(int(round(player_rotation.y)))
	recalculate_obj_marker_pos()

func recalculate_obj_marker_pos():
	for i in extracts.size():
		var extract_pos = extracts[i].global_position
		var obj_marker = obj_markers[i]
		var dir_to_obj = extract_pos - player_pos
		#remove vert
		dir_to_obj.y = 0
		var deg_to_obj = angle_to_deg(Vector3.FORWARD, dir_to_obj)
		var real_deg_to_obj = Helpers.gddeg_to_compass_deg(int(round(deg_to_obj)))
		
		var hscroll_val = degree_to_hscroll(real_deg_to_obj, pixels_per_360)
		obj_marker.position.y = vertical_offset
		obj_marker.position.x = hscroll_val + pixels_per_360/2 - obj_marker.get_rect().size.x/2

static func angle_to_deg(source:Vector3, target:Vector3) -> int:
	var rad_result = source.signed_angle_to(target, Vector3.UP)
	var deg_result = rad_to_deg(rad_result)
	return int(round(deg_result))

## Only use real american 0-360 degrees, not dumb fake communist -180 180 godot degrees. Makes the math much easier
static func degree_to_hscroll(real_degrees:int, scroll_per_360:int) -> float:
	var new_h_s = scroll_per_360 + ((real_degrees * scroll_per_360) /  180.0)
	return new_h_s
