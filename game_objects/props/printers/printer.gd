extends StaticBody3D
class_name PrinterStation

@onready var small_printer_mesh: MeshInstance3D = $small_printer/Cube
@onready var printer_table_mesh: MeshInstance3D = $printer_table
@onready var medium_printer_mesh: MeshInstance3D = $medium_printer/Node/cube

@onready var small_printer_collision_shape_3d: CollisionShape3D = $SmallPrinterCollisionShape3D
@onready var printer_table_collision_shape_3d: CollisionShape3D = $PrinterTableCollisionShape3D
@onready var medium_printer_collision_shape_3d: CollisionShape3D = $MediumPrinterCollisionShape3D


@onready var dissolve_shader_m:ShaderMaterial = load("res://game_objects/effects/dissolve_shader_material.tres")
@onready var redacted_shader_m:ShaderMaterial = load("res://game_objects/effects/redacted_shader_material.tres")


enum PrinterSize {
	UNBUILT,
	SMALL,
	MEDIUM,
	LARGE
}

func _ready():
	HideoutManager.printer_size_changed.connect(_on_printer_size_changed)
	HideoutManager.print_item.connect(_on_print_item)
	_on_printer_size_changed()


func use(player:Player) -> void:
	#toggle_inventory.emit(self)
	player.toggle_printer.emit()

func _on_printer_size_changed():
	match HideoutManager.current_printer_size:
		PrinterSize.UNBUILT:
			show_mesh_hide_others([small_printer_mesh,printer_table_mesh], [medium_printer_mesh])
			small_printer_collision_shape_3d.disabled = false
			printer_table_collision_shape_3d.disabled = false
			medium_printer_collision_shape_3d.disabled = true
			small_printer_mesh.material_override = redacted_shader_m
			printer_table_mesh.material_override = redacted_shader_m
		PrinterSize.SMALL:
			small_printer_mesh.material_override = null
			printer_table_mesh.material_override = null
			show_mesh_hide_others([small_printer_mesh,printer_table_mesh], [medium_printer_mesh])
			small_printer_collision_shape_3d.disabled = true
			printer_table_collision_shape_3d.disabled = false
			medium_printer_collision_shape_3d.disabled = false
		PrinterSize.MEDIUM:
			show_mesh_hide_others([medium_printer_mesh,printer_table_mesh],[small_printer_mesh])

func _on_print_item(item_to_print:ItemInformation):
	var slot_data:SlotData = SlotData.instantiate_from_item_information(item_to_print)
	var scene:Item3D = Item3D.instantiate_from_slot_data(slot_data)
	scene.set_as_top_level(true)		
	LevelManager.add_node_to_level.call_deferred(scene)
	scene.set_global_position.call_deferred($PrintOrigin.global_position)
	var random_rotation = Vector3(randf_range(0,360),randf_range(0,360),randf_range(0,360))
	scene.set_rotation_degrees.call_deferred(random_rotation)
	if scene is RigidBody3D:
		var force_magnitude:float  = randf_range(5,15)
		var x_rotation = randf_range(deg_to_rad(-30.0),deg_to_rad(30.0))
		var z_rotation = randf_range(deg_to_rad(-30.0),deg_to_rad(30.0))
		var vector_to_target = Vector3.UP.rotated(Vector3.RIGHT, x_rotation)
		vector_to_target = vector_to_target.rotated(Vector3.FORWARD, z_rotation)
		vector_to_target.normalized()
		scene.linear_velocity = vector_to_target * force_magnitude
	
	var item_meshes = Helpers.get_all_mesh_nodes(scene)
	show_mesh_hide_others(item_meshes,[])

func show_mesh_hide_others(meshes_to_show:Array[MeshInstance3D], meshes_to_hide:Array[MeshInstance3D]):
	for mesh in meshes_to_hide:
		mesh.visible = false
		mesh.material_override = null
	
	for mesh in meshes_to_show:
		var mesh_material_texture
		var mesh_textures = Helpers.get_textures_from_mesh(mesh)
		if mesh_textures.size() > 0:
			mesh_material_texture = mesh_textures[0]
		var tween = get_tree().create_tween()
		var animation_length = 2.0
		dissolve_shader_m.set_shader_parameter("dissolveSlider", 1.5)
		dissolve_shader_m.set_shader_parameter("baseColorTexture", mesh_material_texture)
		mesh.material_override = dissolve_shader_m.duplicate()
		mesh.material_override.set_meta("remove_on_cleanup",true)
		tween.tween_property(mesh.material_override, "shader_parameter/dissolveSlider", -1.0, animation_length)
		tween.tween_callback(show_mesh_cleanup.bind(mesh))
		mesh.visible = true

func show_mesh_cleanup(mesh:MeshInstance3D):
	if mesh.material_override.has_meta("remove_on_cleanup"):
		mesh.material_override = null
