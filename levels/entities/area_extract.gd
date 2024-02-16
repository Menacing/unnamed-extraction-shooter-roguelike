class_name AreaExtract
extends Area3D
	
@onready var extract_timer:Timer = Timer.new()
var extract_cooldown:float = 10.0

@export var properties: Dictionary :
	get:
		return properties
	set(new_properties):
		if(properties != new_properties):
			properties = new_properties
			update_properties()


func update_properties():
	pass


# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_child(extract_timer)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exit)
	extract_timer.timeout.connect(_on_extract_timer_timeout)
	add_to_group("Extract")


func _on_body_entered(body: Node3D):
	if body is Player:
		extract_timer.start(extract_cooldown)
		pass

func _on_body_exit(body:Node3D):
	if body is Player:
		extract_timer.stop()

func _on_extract_timer_timeout():
	pass
