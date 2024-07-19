extends Node
class_name HealthComponent

##Key: HealthLocation.HEALTH_LOCATION, Value: HealthLocation
@export var health_locs:Dictionary = {}

@onready var parent_id:int = get_parent().get_instance_id()

var main_loc:HealthLocation
var armor_item_instance_id:int = 0

signal health_changed(health_location:HealthLocation)
signal armor_item_instance_id_set(aiii:int)

func _ready():
	health_locs = Helpers.duplicate_deep_workaround_dictionary(health_locs)
	if health_locs.has(HealthLocation.HEALTH_LOCATION.MAIN):
		main_loc = health_locs[HealthLocation.HEALTH_LOCATION.MAIN]
			
	EventBus.location_hit.connect(_on_location_hit)
	EventBus.healed.connect(_on_healed)
	
	pass

func _on_armor_item_instance_id_set(aiii:int):
	armor_item_instance_id = aiii

func _on_location_hit(actor_id:int, location:HealthLocation.HEALTH_LOCATION, \
	damage:float):
	if actor_id == parent_id and health_locs.has(location):
		var loc = health_locs[location]
		if loc.location == location:
			var overflow = false
			var overflow_damage = damage
			if is_zero_approx(loc.current_health):
				overflow = true
			else:
				loc.current_health -= damage
				if loc.current_health <= 0:
					EventBus.location_destroyed.emit(parent_id, loc.location)
					overflow = true
					overflow_damage = -loc.current_health
				else:
					health_changed.emit(loc)
			#handle damage overflow
			if loc.location != main_loc.location and overflow:
				loc.current_health = 0
				health_changed.emit(loc)
				main_loc.current_health -= overflow_damage
				if main_loc.current_health <= 0:
					EventBus.location_destroyed.emit(parent_id, main_loc.location)
					main_loc.current_health = 0
					health_changed.emit(main_loc)

func _on_healed(actor_id:int, healed:float):
	if actor_id == parent_id:
		var remainder = healed
		#heal main first
		if main_loc.current_health < main_loc.max_health:
			remainder = _apply_heal(main_loc, healed)
		if remainder > 0:
			#if we have overheal, heal the other locations
			for i in health_locs:
				var loc = health_locs[i]
				remainder = _apply_heal(loc, remainder)
				if remainder <= 0:
					return

##Apply a given amount of healing, returning any overflow as the remainder
func _apply_heal(loc:HealthLocation, amount:float) -> float:
	if is_zero_approx(loc.current_health) and amount > 0:
		EventBus.location_restored.emit(parent_id, loc.location)
	loc.current_health += amount
	var remainder = loc.current_health - loc.max_health
	if remainder > 0:
		loc.current_health = loc.max_health
		health_changed.emit(loc)
		return remainder
	else:
		health_changed.emit(loc)		
		return 0
