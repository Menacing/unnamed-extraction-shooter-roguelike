extends Control

@onready var use_helper:TextureRect = $use_helper
@onready var pickup_helper:TextureRect = $pickup_helper

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.use_helper_visibility.connect(_on_use_helper_change)
	EventBus.pickup_helper_visibility.connect(_on_pickup_helper_change)
	pass # Replace with function body.


func _on_use_helper_change(show:bool):
	use_helper.visible = show

func _on_pickup_helper_change(show:bool):
	pickup_helper.visible = show
