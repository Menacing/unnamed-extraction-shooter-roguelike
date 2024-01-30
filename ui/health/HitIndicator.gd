extends Control
class_name HitIndicator

var screen_h:int
var screen_w:int
var target_pos:Vector3
var player_pos:Vector3
var player_r:int
@export var icon_margin = 15
@onready var FadeoutTimer:Timer = $FadeoutTimer
@onready var LifeTimer:Timer = $LifeTimer
@onready var icon_tex:TextureRect = $TextureRect
var fading_out:bool = false
var fade_out_amount:float = 0.0
@onready var fade_factor = FadeoutTimer.wait_time

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.compass_player_pulse.connect(_on_compass_player_pulse)
	screen_w = get_viewport().size.x
	screen_h = get_viewport().size.y

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fading_out:
		fade_out_amount += delta * fade_factor
		icon_tex.material.set_shader_parameter("sensitivity", fade_out_amount)
	pass


func _on_timer_timeout():
	fading_out = true
	FadeoutTimer.start()

func _on_compass_player_pulse(player_position:Vector3, player_rotation:Vector3):
	player_pos = player_position
	player_pos.y = 0
	player_r = int(round(player_rotation.y))
	var deg = HitIndicator.deg_to_target(player_pos, player_r, target_pos)
	self.global_position = HitIndicator.add_margin(HitIndicator.deg_to_screen_edge(deg, screen_h, screen_w),screen_h,screen_w,icon_margin)
	var icon_r = deg
	self.rotation_degrees = -icon_r
	
static func deg_to_target(player_pos:Vector3, player_r:int, target_pos:Vector3) -> int:
	player_pos.y = 0
	target_pos.y = 0
	var direction_to_target = target_pos - player_pos
	#Calculate player_heading
	var player_heading:Vector3 = deg_to_vector3(player_r)
	var rad_result = player_heading.signed_angle_to(direction_to_target, Vector3.UP)
	var deg_result = rad_to_deg(rad_result)
	return int(round(deg_result))

static func deg_to_screen_edge(deg:int,screen_h:int, screen_w:int)->Vector2:
	@warning_ignore("integer_division")
	var ste = screen_h/2
	@warning_ignore("integer_division")
	var sre = screen_w/2
	@warning_ignore("integer_division")
	var sbe = -screen_h/2
	@warning_ignore("integer_division")
	var sle = -screen_w/2
	var screen_mag = Vector2(screen_w, screen_h).length()
	@warning_ignore("integer_division")
	var screen_offset = Vector2(screen_w/2,screen_h/2)
	var rdeg = deg_to_rad(deg)
	var direction_vec:Vector2 = deg_to_vector2(deg) * screen_mag
	var slope = direction_vec.y/direction_vec.x
	
	var top_left = Vector2(sle,ste)
	var top_right = Vector2(sre,ste)
	var bottom_left = Vector2(sle,sbe)
	var bottom_right = Vector2(sre,sbe)
	
	var check_top = abs(deg) < 90
	var check_right = deg < 0
	var check_bottom = abs(deg) > 90
	var check_left = deg > 0 
	
	if check_top:
		var top_intersect = Geometry2D.line_intersects_line(Vector2(0,0),direction_vec, top_left, Vector2.RIGHT)
		if top_intersect:
			var screen_coord = convert_to_screen_coordinate(top_intersect, screen_h, screen_w)
			if screen_coord_is_in_view(screen_coord, screen_h, screen_w):
				return screen_coord
	if check_right:
		var right_intersect = Geometry2D.line_intersects_line(Vector2(0,0),direction_vec, top_right, Vector2.DOWN)
		if right_intersect:
			var screen_coord = convert_to_screen_coordinate(right_intersect, screen_h, screen_w)
			if screen_coord_is_in_view(screen_coord, screen_h, screen_w):
				return screen_coord
	if check_bottom:
		var bottom_intersect = Geometry2D.line_intersects_line(Vector2(0,0),direction_vec, bottom_right, Vector2.LEFT)
		if bottom_intersect:
			var screen_coord = convert_to_screen_coordinate(bottom_intersect, screen_h, screen_w)
			if screen_coord_is_in_view(screen_coord, screen_h, screen_w):
				return screen_coord
	if check_left:
		var left_intersect = Geometry2D.line_intersects_line(Vector2(0,0),direction_vec, bottom_left, Vector2.UP)
		if left_intersect:
			var screen_coord = convert_to_screen_coordinate(left_intersect, screen_h, screen_w)
			if screen_coord_is_in_view(screen_coord, screen_h, screen_w):
				return screen_coord
	
	return Vector2()
	
static func deg_to_vector2(deg:int) -> Vector2:
	var deg_r = deg_to_rad(deg+90)
	return Vector2(cos(deg_r), sin(deg_r))
	
static func deg_to_vector3(deg:int) -> Vector3:
	var deg_r = deg_to_rad(deg)
	return Vector3(-sin(deg_r),0, -cos(deg_r))
	
static func screen_coord_is_in_view(vec:Vector2, screen_h:int, screen_w:int) -> bool:
	if(vec.y >= 0 and vec.y <= screen_h and vec.x >= 0 and vec.x <= screen_w ):
		return true
	else:
		return false
	
static func convert_to_screen_coordinate(vec:Vector2, screen_h:int, screen_w:int) -> Vector2:
	@warning_ignore("integer_division")
	var origin = Vector2(screen_w/2,screen_h/2)
	return Vector2(vec.x+origin.x,-vec.y+origin.y)
	
static func add_margin(vec:Vector2, screen_h:int, screen_w:int, margin:int) -> Vector2:
	var ret_vec = vec
	if ret_vec.x == 0:
		ret_vec.x += margin
	if ret_vec.y == 0:
		ret_vec.y += margin
	if ret_vec.x == screen_w:
		ret_vec.x -= margin
	if ret_vec.y == screen_h:
		ret_vec.y -= margin
	return ret_vec


func _on_fadeout_timer_timeout():
	self.queue_free()
