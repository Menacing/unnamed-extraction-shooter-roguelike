@tool
class_name FuncGodotLight
extends Node3D

var light_node: Light3D = null

## func_godot_properties for this entity. Populated from Trenchbroom's entity property editor when building a [QodotMap].
@export var func_godot_properties: Dictionary:
	get:
		return func_godot_properties  # TODO Converter40 Non existent get function
	set(new_properties):
		if func_godot_properties != new_properties:
			func_godot_properties = new_properties
			update_properties()


## Handle updates to [member func_godot_properties]
func update_properties():
	if not Engine.is_editor_hint():
		return
	
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	if 'mangle' in func_godot_properties:
		light_node = SpotLight3D.new()
	
		var yaw = func_godot_properties['mangle'].x
		var pitch = func_godot_properties['mangle'].y
		light_node.rotate(Vector3.UP, deg_to_rad(180 + yaw))
		light_node.rotate(light_node.transform.basis.x, deg_to_rad(180 + pitch))
	
		if 'angle' in func_godot_properties:
			light_node.set_param(Light3D.PARAM_SPOT_ANGLE, func_godot_properties['angle'])
	else:
		light_node = OmniLight3D.new()
	
	var light_brightness = 300
	if 'light' in func_godot_properties:
		light_brightness = func_godot_properties['light']
		light_node.set_param(Light3D.PARAM_ENERGY, light_brightness / 100.0)
		light_node.set_param(Light3D.PARAM_INDIRECT_ENERGY, light_brightness / 100.0)
	
	var light_range := 1.0
	if 'wait' in func_godot_properties:
		light_range = func_godot_properties['wait']
	
	var normalized_brightness = light_brightness / 300.0
	light_node.set_param(Light3D.PARAM_RANGE, 16.0 * light_range * (normalized_brightness * normalized_brightness))
	
	var light_attenuation = 0
	if 'delay' in func_godot_properties:
		light_attenuation = func_godot_properties['delay']
	
	var attenuation = 0
	match light_attenuation:
		0:
			attenuation = 1.0
		1:
			attenuation = 0.5
		2:
			attenuation = 0.25
		3:
			attenuation = 0.15
		4:
			attenuation = 0
		5:
			attenuation = 0.9
		_:
			attenuation = 1
	
	light_node.set_param(Light3D.PARAM_ATTENUATION, attenuation)
	light_node.set_shadow(true)
	light_node.set_bake_mode(Light3D.BAKE_STATIC)
	
	var light_color = Color.WHITE
	if '_color' in func_godot_properties:
		light_color = func_godot_properties['_color']
	
	light_node.set_color(light_color)
	
	add_child(light_node)
	
	if is_inside_tree():
		var tree = get_tree()
		if tree:
			var edited_scene_root = tree.get_edited_scene_root()
			if edited_scene_root:
				light_node.set_owner(edited_scene_root)
