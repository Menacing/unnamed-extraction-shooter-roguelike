extends Object
class_name AttackResult

var percent_penetrated:= 1.0
var damage:float = 0.0
var damage_type:AttackComponent.DamageType = AttackComponent.DamageType.BALLISTIC
var attack_origin:Vector3
var attack_position:Vector3
var attack_normal:Vector3 = Vector3.UP

func _init(pp:float = 1.0):
	percent_penetrated = pp

func _map_from_attack_component(ac:AttackComponent):
	damage = ac.damage
	damage_type = ac.damage_type
	attack_origin = ac.attack_origin
	attack_position = ac.attack_position
	attack_normal = ac.attack_normal
