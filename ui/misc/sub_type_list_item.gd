extends Control
class_name AmmoSubTypeListItem

@export var _ammo_type:AmmoType
@export var _ammo_subtype:AmmoSubtype
@export var current_amount:int

@onready var progress_bar:TextureProgressBar = $SelectionProgressBar
@onready var selection_timer:Timer = $SelectionTimer
@onready var selection_texture:NinePatchRect = $SelectionTexture
@onready var selection_button:Button = $Button

func _ready():
	selection_button.text = _ammo_subtype.name + ": " + str(current_amount)

func select():
	selection_texture.visible = true
	progress_bar.visible = true
	selection_timer.start()
	pass
	
func deselect():
	selection_texture.visible = false
	progress_bar.visible = false
	selection_timer.stop()
	pass

func _on_pressed() -> void:
	EventBus.ammo_type_changed.emit(_ammo_type.name, _ammo_subtype.name)
	pass # Replace with function body.

func _process(delta):
	progress_bar.value = 1.0 - (selection_timer.time_left / selection_timer.wait_time)


func _on_selection_timer_timeout():
	_on_pressed()
	pass # Replace with function body.
