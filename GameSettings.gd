extends Node

var both_eyes_open_ads = true
var toggle_sprint = false
var toggle_crouch = false
var toggle_lean = false
var toggle_ads = false

var h_mouse_sens:float = 5.0
var v_mouse_sens:float = 5.0
var ads_look_factor:float = 1.0

enum HEALTH_DISPLAY {
	BAR,
	ICON,
	NUMBER
}
var selected_health_display:HEALTH_DISPLAY = HEALTH_DISPLAY.BAR
var default_fov:float
