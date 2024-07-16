extends Control

@onready var armor_icon:TextureProgressBar = $VBoxContainer/armor_display/armor_tex_bar
@onready var arm_icon:TextureProgressBar = $VBoxContainer/arm_life_display/arm_tex_bar
@onready var main_icon:TextureProgressBar = $VBoxContainer/main_life_display/main_tex_bar
@onready var leg_icon:TextureProgressBar = $VBoxContainer/leg_life_display/leg_tex_bar

@onready var armor_bar_c:Control = $VBoxContainer/armor_display/armor_bar_container
@onready var arm_bar_c:Control = $VBoxContainer/arm_life_display/arm_bar_container
@onready var main_bar_c:Control = $VBoxContainer/main_life_display/main_bar_container
@onready var leg_bar_c:Control = $VBoxContainer/leg_life_display/leg_bar_container

@onready var armor_bar:ProgressBar = $VBoxContainer/armor_display/armor_bar_container/HBoxContainer/LifeBar
@onready var arm_bar:ProgressBar = $VBoxContainer/arm_life_display/arm_bar_container/HBoxContainer/LifeBar
@onready var main_bar:ProgressBar = $VBoxContainer/main_life_display/main_bar_container/HBoxContainer/LifeBar
@onready var leg_bar:ProgressBar = $VBoxContainer/leg_life_display/leg_bar_container/HBoxContainer/LifeBar

@onready var armor_label_c:Label = $VBoxContainer/armor_display/armor_text_container/armor_text_hbox_container/current_health_label
@onready var armor_label_m:Label = $VBoxContainer/armor_display/armor_text_container/armor_text_hbox_container/max_health_label
@onready var arm_label_c:Label = $VBoxContainer/main_life_display/main_text_container/main_text_hbox_container/current_health_label
@onready var arm_label_m:Label = $VBoxContainer/main_life_display/main_text_container/main_text_hbox_container/max_health_label
@onready var main_label_c:Label = $VBoxContainer/main_life_display/main_text_container/main_text_hbox_container/current_health_label
@onready var main_label_m:Label = $VBoxContainer/main_life_display/main_text_container/main_text_hbox_container/max_health_label
@onready var leg_label_c:Label = $VBoxContainer/leg_life_display/leg_text_container/main_text_hbox_container/current_health_label
@onready var leg_label_m:Label = $VBoxContainer/leg_life_display/leg_text_container/main_text_hbox_container/max_health_label
@onready var armor_label_container:Control = $VBoxContainer/armor_life_display/armor_text_container
@onready var arm_label_container:Control = $VBoxContainer/arm_life_display/arm_text_container
@onready var main_label_container:Control = $VBoxContainer/main_life_display/main_text_container
@onready var leg_label_container:Control = $VBoxContainer/leg_life_display/leg_text_container

var arm_c:float
var arm_m:float
var main_c:float
var main_m:float
var leg_c:float
var leg_m:float

var armor_item_instance_id:int = 0

@export var health_component:HealthComponent

# Called when the node enters the scene tree for the first time.
func _ready():
	health_component.health_changed.connect(_on_health_changed)
	set_health_mode()

func _on_armor_item_instance_id_set(aiii:int):
	armor_item_instance_id = aiii

func _on_health_changed(loc:HealthLocation):
	match loc.location:
		HealthLocation.HEALTH_LOCATION.ARMS:
			arm_c = loc.current_health
			arm_m = loc.max_health
		HealthLocation.HEALTH_LOCATION.LEGS:
			leg_c = loc.current_health
			leg_m = loc.max_health
		HealthLocation.HEALTH_LOCATION.MAIN:
			main_c = loc.current_health
			main_m = loc.max_health
	update_display_values()
	set_health_mode()

func update_display_values():
	arm_icon.value = arm_c
	arm_icon.max_value = arm_m
	arm_bar.value = arm_c
	arm_bar.max_value = arm_m
	arm_label_c.text = str(roundi(arm_c))
	arm_label_m.text = str(roundi(arm_m))
	
	main_icon.value = main_c
	main_icon.max_value = main_m
	main_bar.value = main_c
	main_bar.max_value = main_m
	main_label_c.text = str(roundi(main_c))
	main_label_m.text = str(roundi(main_m))
	
	leg_icon.value = leg_c
	leg_icon.max_value = leg_m
	leg_bar.value = leg_c
	leg_bar.max_value = leg_m
	leg_label_c.text = str(roundi(leg_c))
	leg_label_m.text = str(roundi(leg_m))

func set_health_mode():
	if GameSettings.selected_health_display == GameSettings.HEALTH_DISPLAY.BAR:
		armor_bar_c.visible = true
		arm_bar_c.visible = true
		main_bar_c.visible = true
		leg_bar_c.visible = true
		
		armor_icon.visible = false
		arm_icon.visible = false
		main_icon.visible = false
		leg_icon.visible = false
		
		armor_label_container.visible = false
		arm_label_container.visible = false
		main_label_container.visible = false
		leg_label_container.visible = false
		
	if GameSettings.selected_health_display == GameSettings.HEALTH_DISPLAY.ICON:
		armor_bar_c.visible = false
		arm_bar_c.visible = false
		main_bar_c.visible = false
		leg_bar_c.visible = false
		
		armor_icon.visible = true
		arm_icon.visible = true
		main_icon.visible = true
		leg_icon.visible = true
		
		armor_label_container.visible = false
		arm_label_container.visible = false
		main_label_container.visible = false
		leg_label_container.visible = false
		
	if GameSettings.selected_health_display == GameSettings.HEALTH_DISPLAY.NUMBER:
		armor_bar_c.visible = false
		arm_bar_c.visible = false
		main_bar_c.visible = false
		leg_bar_c.visible = false
		
		armor_icon.visible = false
		arm_icon.visible = false
		main_icon.visible = false
		leg_icon.visible = false
		
		armor_label_container.visible = true
		arm_label_container.visible = true
		main_label_container.visible = true
		leg_label_container.visible = true

func _on_item_durability_changed(item_instance:ItemInstance):
	if armor_item_instance_id and armor_item_instance_id !=0 and item_instance and item_instance.item_instance_id == armor_item_instance_id:
		var dur:float = item_instance.durability
		var max_dur:float = item_instance.get_max_durability()
		armor_icon.value = dur
		armor_icon.max_value = max_dur
		armor_bar.value = dur
		armor_bar.max_value = dur
		armor_label_c.text = str(roundi(dur))
		armor_label_m.text = str(roundi(max_dur))
		set_health_mode()
