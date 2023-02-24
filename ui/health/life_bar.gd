extends Control

@onready var life_bar:ProgressBar = $LifeBar

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.set_health.connect(_on_health_changed)


func _on_health_changed(current_health:float, max_health:float):
	life_bar.value = current_health
	life_bar.max_value = max_health
	
