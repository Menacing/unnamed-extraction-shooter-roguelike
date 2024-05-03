@tool
extends StaticBody3D
class_name FuncGeo

const INVERSE_SCALE: float = 1.0 / 32.0

@export var func_godot_properties: Dictionary = {} :
	set(value):
		func_godot_properties = value;
		
		if !Engine.is_editor_hint():
			return
		
		for child in get_children():
			if child.get_class() == "MeshInstance3D":
				var m: MeshInstance3D = child
				m.set_gi_mode(GeometryInstance3D.GI_MODE_STATIC);
				m.set_cast_shadows_setting((func_godot_properties["cast_shadow"] as GeometryInstance3D.ShadowCastingSetting))
				if get_parent() is FuncGodotMap and m.mesh.get_class() == "ArrayMesh":
					(m.mesh as ArrayMesh).lightmap_unwrap(Transform3D(), (get_parent() as FuncGodotMap).inverse_scale_factor)
	get:
		return func_godot_properties
