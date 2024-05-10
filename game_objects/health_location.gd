extends Resource
class_name HealthLocation

enum HEALTH_LOCATION {
	LEGS,
	MAIN,
	ARMS
}

@export var location:HEALTH_LOCATION
@export var current_health:float
@export var max_health:float
