extends Node
class_name HealthComponent

@export var health_locs:Array[HealthLocation]

@onready var parent_id:int = get_parent().get_instance_id()

var main_loc:HealthLocation

func _ready():
	for i in range(health_locs.size()):
		if health_locs[i].location == HealthLocation.HEALTH_LOCATION.MAIN:
			main_loc = health_locs[i]
			
	EventBus.location_hit.connect(_on_location_hit)
	EventBus.healed.connect(_on_healed)
	pass

func _process(delta):
	EventBus.player_health_pulse.emit(health_locs)

func _on_location_hit(actor_id:int, location:HealthLocation.HEALTH_LOCATION, \
	damage:float):
	if actor_id == parent_id:
		for i in range(health_locs.size()):
			var loc = health_locs[i]
			if loc.location == location:
				loc.current_health -= damage
				if loc.current_health <= 0:
					EventBus.location_destroyed.emit(parent_id, loc.location)
					#handle damage overflow
					if loc.location != main_loc.location:
						var overflow_damage = -loc.current_health
						loc.current_health = 0
						main_loc.current_health -= overflow_damage
						if main_loc.current_health <= 0:
							EventBus.location_destroyed.emit(parent_id, main_loc.location)

func _on_healed(actor_id:int, healed:float):
	if actor_id == parent_id:
		var remainder = healed
		#heal main first
		if main_loc.current_health < main_loc.max_health:
			remainder = _apply_heal(main_loc, healed)
		if remainder > 0:
			#if we have overheal, heal the other locations
			for i in range(health_locs.size()):
				var loc = health_locs[i]
				remainder = _apply_heal(loc, remainder)
				if remainder <= 0:
					return

##Apply a given amount of healing, returning any overflow as the remainder
func _apply_heal(loc:HealthLocation, amount:float) -> float:
	loc.current_health += amount
	var remainder = loc.current_health - loc.max_health
	if remainder > 0:
		loc.current_health = loc.max_health
		return remainder
	else:
		return 0
