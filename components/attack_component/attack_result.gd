extends Object
class_name AttackResult

var percent_penetrated:= 1.0
var damage_type:AttackComponent.DamageType = AttackComponent.DamageType.BALLISTIC
var attack_origin:Vector3
var attack_location:Vector3

func _init(pp:=1.0):
	percent_penetrated = pp
