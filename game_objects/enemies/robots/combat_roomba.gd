extends Enemy

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var head = %Head as Node3D
@export var gun_scene: PackedScene
var gun: Gun
var hf_pos: Vector3
@export var health:float = 100.0
var accel = 3
var turret_rotation:float = 2.0

var alive = true
var last_damage_normal:Vector3
var last_damage:float



# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	self_exclusions = Helpers.get_all_collision_object_3d_recursive(self)
	exclusions = self_exclusions
	
	if gun_scene: 
		gun = gun_scene.instantiate()
		gun.start_highlighted = false
		gun.picked_up()
		#TODO: Pull these from the packed scene instead of being hardcoded
		gun._gun_stats.magazine_size = 30000
		gun.current_magazine_size = 30000
		hf_pos = -gun.get_hip_fire_anchor()

		gun.position = hf_pos
		head.add_child(gun)
		gun.firer = self
		gun_node = gun

func die():
	super()
	alive = false
	$CollisionShape3D.disabled = true
	$CollisionShape3D2.disabled = true
	$CollisionShape3D3.disabled = true
	$"combat-roomba/Armature/Skeleton3D/PhysicalBoneSimulator3D/Head/SpotLight3D".visible = false




func _on_game_saving(save_file:SaveFile):
	if save_file:
		var enemy_information:TopLevelEntitySaveData = TopLevelEntitySaveData.new()
		enemy_information.global_transform = self.global_transform
		#player_information.path_to_parent = self.get_parent().get_path()
		enemy_information.scene_path = self.scene_file_path
		enemy_information.additional_data["health"] = health
		save_file.top_level_entity_save_data.append(enemy_information)

func _on_game_before_loading():
	self.queue_free()
	
func _on_load_game(save_data:TopLevelEntitySaveData):
	if save_data:
		self.global_transform = save_data.global_transform
		self.health = save_data.additional_data["health"]
		if health <= 0:
			die()


func _on_health_component_location_destroyed(health_component: HealthComponent) -> void:
	die()
