extends Node3D
class_name AttackComponent

@export var damage:float = 0.0
enum DamageType {
	BALLISTIC,
	MELEE
}
@export var damage_type:DamageType = DamageType.BALLISTIC
@export var armor_penetration_rating:int = 0
@export var attack_origin:Vector3
@export var attack_position:Vector3
@export var attack_normal:Vector3
