extends Node

func _ready():
	GGS.setting_applied.connect(_on_ggs_setting_applied)
	for ggs_setting:ggsSetting in GGS._get_all_settings():
		_on_ggs_setting_applied(ggs_setting.key, GGS.get_value(ggs_setting))

var both_eyes_open_ads = true
var toggle_sprint = false
var toggle_crouch = false
var toggle_lean = false
var toggle_ads = false
var disable_use_helper_when_ads = true

var h_mouse_sens:float = 5.0
var v_mouse_sens:float = 5.0
var ads_look_factor:float = 1.0

enum HEALTH_DISPLAY {
	BAR,
	ICON,
	NUMBER
}
var selected_health_display:HEALTH_DISPLAY = HEALTH_DISPLAY.BAR
var default_fov:float = 75.0

func _on_ggs_setting_applied(setting: String, value: Variant):
	match setting:
		"both_eyes_open":
			both_eyes_open_ads = value
		"toggle_sprint":
			toggle_sprint = value
		"toggle_crouch":
			toggle_crouch = value
		"toggle_lean":
			toggle_lean = value
		"toggle_ads":
			toggle_ads = value
		"ads_look_factor":
			ads_look_factor = value
		"h_mouse_sens":
			h_mouse_sens = value
		"v_mouse_sens":
			v_mouse_sens
