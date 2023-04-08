extends Node

var both_eyes_open_ads = true
var toggle_sprint = false
var toggle_crouch = false
var toggle_lean = false
var toggle_ads = true

func _ready():
	var config = ConfigFile.new()
	var err = config.load("res://game_settings.cfg")
	if err == OK:
		for player in config.get_sections():
			both_eyes_open_ads = config.get_value(player, "both_eyes_open_ads")
			toggle_sprint = config.get_value(player, "toggle_sprint")
			toggle_crouch = config.get_value(player, "toggle_crouch")
			toggle_lean = config.get_value(player, "toggle_lean")
			toggle_ads = config.get_value(player, "toggle_ads")
