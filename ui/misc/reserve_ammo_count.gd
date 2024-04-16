extends Control

@onready var ammo_type_label:Label = $VBoxContainer/HBoxContainer/AmmoType
@onready var ammo_subtype_label:Label = $VBoxContainer/HBoxContainer/AmmoSubtype
@onready var reserve_ammo_count:Label = $VBoxContainer/ReserveAmmoCount
# Called when the node enters the scene tree for the first time.


func _ready():
	pass
	EventBus.active_reserve_ammo_count_changed.connect(_on_reserve_ammo_count_changed)
	EventBus.ammo_type_changed.connect(_on_ammo_type_changed)

func _on_reserve_ammo_count_changed(new_count:int):
	reserve_ammo_count.text = str(new_count)

func _on_ammo_type_changed(new_type:String, new_subtype:String):
	var ammo_type:AmmoType = AmmoLoader.get_ammo_type(new_type)
	var ammo_subtype:AmmoSubtype = AmmoLoader.get_ammo_subtype(new_type, new_subtype)
	
	ammo_type_label.text = ammo_type.abbreviation
	ammo_subtype_label.text = ammo_subtype.abbreviation
