extends StaticBody3D
class_name PrinterStation

@onready var small_printer_mesh: MeshInstance3D = $small_printer/Cube
@onready var printer_table_mesh: MeshInstance3D = $printer_table
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
	_on_printer_size_changed()


func use(player:Player) -> void:
	#toggle_inventory.emit(self)
	player.toggle_printer.emit()

func _on_printer_size_changed():
	match HideoutManager.current_printer_size:
		PrinterSize.UNBUILT:
			small_printer_mesh.material_override = redacted_shader_m
			printer_table_mesh.material_override = redacted_shader_m
		PrinterSize.SMALL:
			small_printer_mesh.material_override = null
			printer_table_mesh.material_override = null
			show_mesh_hide_others([small_printer_mesh,printer_table_mesh], [])

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
		tween.tween_property(mesh.material_override, "shader_parameter/dissolveSlider", -1.0, animation_length)
		tween.tween_callback(show_mesh_cleanup.bind(mesh))
		mesh.visible = true

func show_mesh_cleanup(mesh:MeshInstance3D):
	mesh.material_override = null
