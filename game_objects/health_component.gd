extends Node
class_name HealthComponent

enum HEALTH_LOCATION {
	LEGS,
	MAIN,
	ARMS
}

@export var location:HEALTH_LOCATION
@export var current_health:float
@export var max_health:float

@onready var parent_id:int = get_parent().get_instance_id()

@export var heal_overflow_locations:Array[HealthComponent]
@export var damage_overflow_locations:Array[HealthComponent]

var is_destroyed:bool = false

signal health_changed(health_component:HealthComponent)
signal location_destroyed(health_component:HealthComponent)
signal location_restored(health_component:HealthComponent)

func _ready():
	#EventBus.healed.connect(_on_healed)
	pass

func destroy_location():
	if !is_destroyed:
		is_destroyed = true
		location_destroyed.emit(self)

func restore_location():
	if is_destroyed:
		is_destroyed = false
		location_restored.emit(self)

##Apply a given amount of damage, returning any overflow as the remainder
func apply_damage(damage:float) -> float:
	var overflow_damage:float = 0.0
	current_health -= damage
	if current_health < 0:
		overflow_damage = -current_health
		current_health = 0.0
		destroy_location()
		
		if !is_zero_approx(overflow_damage):
			for hc:HealthComponent in damage_overflow_locations:
				overflow_damage = hc.apply_damage(overflow_damage)
				if is_zero_approx(overflow_damage):
					overflow_damage = 0.0
					break
	health_changed.emit(self)
	return overflow_damage
	pass

##Apply a given amount of healing, returning any overflow as the remainder
func apply_healing(healing_amount:float) -> float:
	var overflow_healing := 0.0
	current_health += healing_amount
	restore_location()
	if current_health > max_health:
		overflow_healing = current_health - max_health
		current_health = max_health
		
		if !is_zero_approx(overflow_healing):
			for hc:HealthComponent in heal_overflow_locations:
				overflow_healing = hc.apply_healing(overflow_healing)
				if is_zero_approx(overflow_healing):
					overflow_healing = 0.0
					break
	health_changed.emit(self)
	return overflow_healing

func _on_game_saving(tlesd:TopLevelEntitySaveData):
	tlesd.additional_data[name+"_current_health"] = current_health
	tlesd.additional_data[name+"_destroyed"] = is_destroyed
	tlesd.additional_data[name+"_max_health"] = max_health

func _on_load_game(tlesd:TopLevelEntitySaveData):
	current_health = tlesd.additional_data[name+"_current_health"]
	is_destroyed = tlesd.additional_data[name+"_destroyed"]
	max_health = tlesd.additional_data[name+"_max_health"]


func _on_hit_occured(damage_result:AttackResult):
	apply_damage(damage_result.damage)
	pass # Replace with function body.
