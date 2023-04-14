extends Node
class_name HealthComponent

@export var health_locs:Array[HealthLocation]

@onready var parent_id:int = get_parent().get_instance_id()

var main_loc:HealthLocation

func _ready():
	for i in range(health_locs.size()):
		if health_locs[i].location == HealthLocation.HEALTH_LOCATION.MAIN:
			main_loc = health_locs[i]
			
	Events.location_hit.connect(_on_location_hit)
	pass

func _process(delta):
	Events.player_health_pulse.emit(health_locs)

func _on_location_hit(actor_id:int, location:HealthLocation.HEALTH_LOCATION, \
	damage:float):
	if actor_id == parent_id:
		for i in range(health_locs.size()):
			var loc = health_locs[i]
			if loc.location == location:
				loc.current_health -= damage
				if loc.current_health <= 0:
					Events.location_destroyed.emit(parent_id, loc.location)
					#handle damage overflow
					if loc.location != main_loc.location:
						var overflow_damage = -loc.current_health
						loc.current_health = 0
						main_loc.current_health -= overflow_damage
						if main_loc.current_health <= 0:
							Events.location_destroyed.emit(parent_id, main_loc.location)
