class_name AreaExtract
extends Area3D
	
@onready var extract_timer:Timer = Timer.new()
var extract_cooldown:float = 10.0
var extract_message_template:String = "Extraction in %.3f"

@export var func_godot_properties: Dictionary

func _func_godot_apply_properties(entity_properties: Dictionary):
	pass


# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_child(extract_timer)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exit)
	extract_timer.timeout.connect(_on_extract_timer_timeout)
	add_to_group("Extract")

func _physics_process(delta: float) -> void:
	if !extract_timer.is_stopped():
		EventBus.update_message.emit(str(get_instance_id()), extract_message_template % extract_timer.time_left)
	pass

func _on_body_entered(body: Node3D):
	if body is Player:
		extract_timer.start(extract_cooldown)
		EventBus.create_message.emit(str(get_instance_id()), extract_message_template % extract_cooldown, -1)		
		pass

func _on_body_exit(body:Node3D):
	if body is Player:
		extract_timer.stop()
		EventBus.remove_message.emit(str(get_instance_id()))		
		

func _on_extract_timer_timeout():
	EventBus.remove_message.emit(str(get_instance_id()))		
	MenuManager.load_menu(MenuManager.MENU_LEVEL.EXTRACTED)
	pass
