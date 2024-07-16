# GdUnit generated TestSuite
class_name Player_test
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

const __source = "res://game_objects/player/player.gd"

var player_scene:PackedScene = load("res://game_objects/player/player.tscn")

func test_player_queues_free_with_no_orphans() -> void:
	var player = player_scene.instantiate()
	self.add_child(player)
	
	player.queue_free()
	
func test_on_game_before_loading() -> void:
	var player = player_scene.instantiate()
	self.add_child(player)
	
	EventBus.before_game_loading.emit()
	
