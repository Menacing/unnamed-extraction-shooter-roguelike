extends Item3D
class_name BodyArmor

@export var pen_ratio = 1.0
@export var armor_rating: int = 6

func _on_hit(damage, pen_rating, col:CollisionInformation, hit_origin:Vector3) -> float:
	if pen_rating >= armor_rating:
		_item_instance.durability -= damage/2
		return pen_ratio
		print("Took %s damage, pen rating %s. Remaining dur: %s" % [damage, pen_rating, _item_instance.durability])
	else:
		_item_instance.durability -= damage
		print("Took %s damage, pen rating %s. Remaining dur: %s" % [damage, pen_rating, _item_instance.durability])
		return 0.0

#https://docs.godotengine.org/en/latest/tutorials/physics/physics_introduction.html#collision-layers-and-masks
var ballistic_layer_bitmask = 2
var ballistic_mask_bitmask = 2
var existing_layer_bitmask
var existing_mask_bitmask

func picked_up():
	self.transform = Transform3D.IDENTITY
	existing_layer_bitmask = self.collision_layer
	existing_mask_bitmask = self.collision_mask
	self.collision_layer = ballistic_layer_bitmask
	self.collision_mask = ballistic_mask_bitmask
	set_material_overlay(null)
	self.freeze = true

func dropped():
	self.collision_layer = existing_layer_bitmask
	self.collision_mask = existing_mask_bitmask
	set_material_overlay(item_highlight_m)
	self.freeze = false
	self.apply_torque_impulse(Vector3.FORWARD)