@tool
class_name StashContainer
extends GeoBallisticSolid

enum StashSize {
	SMALL = 4,
	MEDIUM = 8,
	LARGE = 16
}

@onready var item_highlight_m:ShaderMaterial = load("res://themes/item_highlighter_m.tres")
@onready var dissolve_shader_m:ShaderMaterial = load("res://game_objects/effects/dissolve_shader_material.tres")

@onready var small_stash_2: MeshInstance3D = $small_stash2/small_stash
@onready var small_stash_collision_shape_3d: CollisionShape3D = $SmallStashCollisionShape3D


@onready var medium_stash_2: MeshInstance3D = $medium_stash2/medium_stash
@onready var medium_stash_collision_shape_3d: CollisionShape3D = $MediumStashCollisionShape3D


signal toggle_inventory(external_inventory_owner)

@export var inventory_data:InventoryData

func use(player:Player) -> void:
	#toggle_inventory.emit(self)
	player.toggle_stash.emit()


func _ready():
	inventory_data.inventory_size_changed.connect(_on_stash_size_changed)
	inventory_data.set_inventory_size(HideoutManager.current_stash_size)
	HideoutManager.inventory_data = inventory_data
	_on_stash_size_changed(inventory_data, HideoutManager.current_stash_size)

func _on_stash_size_changed(inv_data:InventoryData, new_size:int) -> void:
	match new_size:
		StashSize.SMALL:
			small_stash_collision_shape_3d.disabled = false
			medium_stash_collision_shape_3d.disabled = true
			
			show_mesh_hide_others(small_stash_2, [medium_stash_2])
		StashSize.MEDIUM:
			small_stash_collision_shape_3d.disabled = true
			medium_stash_collision_shape_3d.disabled = false
			
			show_mesh_hide_others(medium_stash_2, [small_stash_2])
		StashSize.LARGE:
			pass
		_:
			printerr("Setting stash to invalide size")
	pass

func show_mesh_hide_others(mesh_to_show:MeshInstance3D, meshes_to_hide:Array[MeshInstance3D]):
	for mesh in meshes_to_hide:
		mesh.visible = false
		mesh.material_override = null
	
	var mesh_material_texture
	var mesh_textures = Helpers.get_textures_from_mesh(mesh_to_show)
	if mesh_textures.size() > 0:
		mesh_material_texture = mesh_textures[0]
	var tween = get_tree().create_tween()
	var animation_length = 2.0
	dissolve_shader_m.set_shader_parameter("dissolveSlider", 1.5)
	dissolve_shader_m.set_shader_parameter("baseColorTexture", mesh_material_texture)
	mesh_to_show.material_override = dissolve_shader_m.duplicate()
	tween.tween_property(mesh_to_show.material_override, "shader_parameter/dissolveSlider", -1.0, animation_length)
	tween.tween_callback(show_mesh_cleanup.bind(mesh_to_show))
	mesh_to_show.visible = true

func show_mesh_cleanup(mesh:MeshInstance3D):
	mesh.material_override = null
