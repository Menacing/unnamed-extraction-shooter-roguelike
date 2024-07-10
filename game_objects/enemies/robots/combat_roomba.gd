extends Enemy

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var head = $"combat-roomba/Armature/Skeleton3D/Physical Bone Bone/Head" as Node3D
@export var gun_scene: PackedScene
@export var hit_effect: PackedScene = load("res://game_objects/effects/bullet_hit_sparks.tscn")
var gun: Gun
var hf_pos: Vector3
@export var health:float = 100.0
var accel = 3
var turret_rotation:float = 2.0

@onready var skeleton:Skeleton3D = $"combat-roomba/Armature/Skeleton3D"
@onready var physical_bone:PhysicalBone3D = $"combat-roomba/Armature/Skeleton3D/Physical Bone Bone"
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

#func _physics_process(delta):
	#super(delta)
	#if alive:
		#if player_aimpoint:
			#Helpers.slow_rotate_to_point(head, player_aimpoint.global_transform.origin, turret_rotation, delta)
			#Helpers.slow_rotate_to_point(gun, player_aimpoint.global_transform.origin, turret_rotation, delta)

func _on_took_damage(damage:float):
	health-=damage
	if health < 0:
		die()
		
func die():
	print("I am dead")
	alive = false
	skeleton.animate_physical_bones = true
	skeleton.physical_bones_start_simulation()
	var damage_vector = last_damage_normal.normalized() * 5
	PhysicsServer3D.body_set_state(physical_bone.get_rid(), PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY, damage_vector)
	$CollisionShape3D.disabled = true
	$CollisionShape3D2.disabled = true
	$CollisionShape3D3.disabled = true
	$"combat-roomba/Armature/Skeleton3D/Physical Bone Bone/Head/SpotLight3D".visible = false
	var behavior_tree:BTPlayer = $BTPlayer
	behavior_tree.active = false
#	var inv_node = inv.instantiate()
#	inv_node.container_size = container_size
#	Events.create_inventory.emit(inv_node,self.name)

@export var pen_ratio:float = 1.0
@export var damage_multiplier = 1.0

func _on_hit(damage, pen_rating, col:CollisionInformation, hit_origin:Vector3) -> float:
	damage = damage * damage_multiplier
	print("Took %s damage, pen rating %s at %s" % [damage, pen_rating, col.position])
	last_damage_normal = col.normal
	last_damage = damage
	_on_took_damage(damage)
	var normal = col.normal
	
	if hit_effect:
		var hit_inst = hit_effect.instantiate() as Node3D
		hit_inst.set_as_top_level(true)
		get_parent().add_child(hit_inst)
		hit_inst.global_transform.origin = position
		hit_inst.look_at(normal+position,Vector3.UP)
	
	return pen_ratio

func _on_game_saving(save_file:SaveFile):
	if save_file:
		var enemy_information:SaveData = SaveData.new()
		enemy_information.global_transform = self.global_transform
		#player_information.path_to_parent = self.get_parent().get_path()
		enemy_information.scene_path = self.scene_file_path
		enemy_information.additional_data["health"] = health
		save_file.save_data.append(enemy_information)

func _on_game_before_loading():
	self.queue_free()
	
func _on_load_game(save_data:SaveData):
	if save_data:
		self.global_transform = save_data.global_transform
		self.health = save_data.additional_data["health"]
		if health <= 0:
			die()
