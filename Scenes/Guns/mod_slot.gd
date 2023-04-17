extends Resource
class_name ModSlot

enum ModType {
	OPTIC,
	GRIP,
	MAG,
	STOCK,
	MUZZLE,
	FOREGRIP,
	LASER
}


@export var slot_location:Vector2 = Vector2.ZERO
@export var slot_type:ModSlot.ModType
