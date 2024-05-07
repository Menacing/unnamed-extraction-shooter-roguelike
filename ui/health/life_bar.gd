extends Control

@onready var arm_icon:TextureProgressBar = $VBoxContainer/arm_life_display/arm_tex_bar
@onready var main_icon:TextureProgressBar = $VBoxContainer/main_life_display/main_tex_bar
@onready var leg_icon:TextureProgressBar = $VBoxContainer/leg_life_display/leg_tex_bar

@onready var arm_bar_c:Control = $VBoxContainer/arm_life_display/arm_bar_container
@onready var main_bar_c:Control = $VBoxContainer/main_life_display/main_bar_container
@onready var leg_bar_c:Control = $VBoxContainer/leg_life_display/leg_bar_container

@onready var arm_bar:ProgressBar = $VBoxContainer/arm_life_display/arm_bar_container/HBoxContainer/LifeBar
@onready var main_bar:ProgressBar = $VBoxContainer/main_life_display/main_bar_container/HBoxContainer/LifeBar
@onready var leg_bar:ProgressBar = $VBoxContainer/leg_life_display/leg_bar_container/HBoxContainer/LifeBar

@onready var arm_label_c:Label = $VBoxContainer/main_life_display/main_text_container/main_text_hbox_container/current_health_label
@onready var arm_label_m:Label = $VBoxContainer/main_life_display/main_text_container/main_text_hbox_container/max_health_label
@onready var main_label_c:Label = $VBoxContainer/main_life_display/main_text_container/main_text_hbox_container/current_health_label
@onready var main_label_m:Label = $VBoxContainer/main_life_display/main_text_container/main_text_hbox_container/max_health_label
@onready var leg_label_c:Label = $VBoxContainer/leg_life_display/leg_text_container/main_text_hbox_container/current_health_label
@onready var leg_label_m:Label = $VBoxContainer/leg_life_display/leg_text_container/main_text_hbox_container/max_health_label

var arm_c:float
var arm_m:float
var main_c:float
var main_m:float
var leg_c:float
var leg_m:float

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.player_health_pulse.connect(_on_player_health_pulse)
	set_health_mode()


func _on_player_health_pulse(health:Array[HealthLocation]):
	for i in range(health.size()):
		match health[i].location:
			HealthLocation.HEALTH_LOCATION.ARMS:
				arm_c = health[i].current_health
				arm_m = health[i].max_health
			HealthLocation.HEALTH_LOCATION.LEGS:
				leg_c = health[i].current_health
				leg_m = health[i].max_health
			HealthLocation.HEALTH_LOCATION.MAIN:
				main_c = health[i].current_health
				main_m = health[i].max_health
	update_display_values(arm_c, arm_m, main_c, \
	main_m, leg_c, leg_m)
	set_health_mode()
	pass

func update_display_values(arm_c:float, arm_m:float, main_c:float, \
	main_m:float, leg_c:float, leg_m:float):
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
		arm_bar_c.visible = true
		main_bar_c.visible = true
		leg_bar_c.visible = true
		
		arm_icon.visible = false
		main_icon.visible = false
		leg_icon.visible = false
		
		arm_label_c.visible = false
		arm_label_m.visible = false
		main_label_c.visible = false
		main_label_m.visible = false
		leg_label_c.visible = false
		leg_label_m.visible = false
		
	if GameSettings.selected_health_display == GameSettings.HEALTH_DISPLAY.ICON:
		arm_bar_c.visible = false
		main_bar_c.visible = false
		leg_bar_c.visible = false
		
		arm_icon.visible = true
		main_icon.visible = true
		leg_icon.visible = true
		
		arm_label_c.visible = false
		arm_label_m.visible = false
		main_label_c.visible = false
		main_label_m.visible = false
		leg_label_c.visible = false
		leg_label_m.visible = false
		
	if GameSettings.selected_health_display == GameSettings.HEALTH_DISPLAY.NUMBER:
		arm_bar_c.visible = false
		main_bar_c.visible = false
		leg_bar_c.visible = false
		
		arm_icon.visible = false
		main_icon.visible = false
		leg_icon.visible = false
		
		arm_label_c.visible = true
		arm_label_m.visible = true
		main_label_c.visible = true
		main_label_m.visible = true
		leg_label_c.visible = true
		leg_label_m.visible = true
