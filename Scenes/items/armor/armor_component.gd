extends ItemComponent
class_name ArmorComponent

#https://docs.godotengine.org/en/latest/tutorials/physics/physics_introduction.html#collision-layers-and-masks
var ballistic_layer_bitmask = 2
var ballistic_mask_bitmask = 2
var existing_layer_bitmask
var existing_mask_bitmask

func picked_up():
	var parent:PhysicsBody3D = get_parent()
	parent.transform = Transform3D.IDENTITY
	existing_layer_bitmask = parent.collision_layer
	existing_mask_bitmask = parent.collision_mask
	parent.collision_layer = ballistic_layer_bitmask
	parent.collision_mask = ballistic_mask_bitmask
	set_material_overlay(null)
	parent.freeze = true

func dropped():
	var parent = get_parent()
	parent.collision_layer = existing_layer_bitmask
	parent.collision_mask = existing_mask_bitmask
	set_material_overlay(item_highlight_m)
	parent.freeze = false
	if parent is RigidBody3D:
		parent.apply_torque_impulse(Vector3.FORWARD)
