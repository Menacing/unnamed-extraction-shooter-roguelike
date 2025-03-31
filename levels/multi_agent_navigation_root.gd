@tool
extends Node3D
class_name MultiAgentNavigationRoot

@export var navigation_mesh_list_items:Array[NavigationMeshListItem]

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	
	if navigation_mesh_list_items == null or navigation_mesh_list_items.size() == 0:  # Check if the value is unset or invalid
		warnings.append("Must set Navigation Mesh List Items or no nav meshes will be calculated")
	
	return warnings

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.level_loaded.connect(_setup)
	
func _setup():
	LevelManager.level_navigation_maps = {}
	
	# Create the source geometry resource that will hold the parsed geometry data.
	var source_geometry_data: NavigationMeshSourceGeometryData3D = NavigationMeshSourceGeometryData3D.new()
	
	# Parse the source geometry from the scene tree on the main thread.
	# The navigation mesh is only required for the parse settings so any of the three will do.
	var sample_navigation_mesh:NavigationMesh = NavigationMesh.new()
	sample_navigation_mesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS 
	# Binary - set the bit corresponding to the layers you want to enable (1, 3, and 4) to 1, set all other bits to 0.
	# Note: Layer 32 is the first bit, layer 1 is the last. The mask for layers 4,3 and 1 is therefore
	var collision_mask = 0b00000000_00000000_00000000_0000001
	sample_navigation_mesh.geometry_collision_mask = collision_mask
	NavigationServer3D.parse_source_geometry_data(sample_navigation_mesh, source_geometry_data, self)
	
	var parsed_source_geometry_has_data = source_geometry_data.has_data()
	var calculated_vertices = source_geometry_data.get_vertices()
	if calculated_vertices.size() == 0:
		printerr("parsed mesh is empty!")

	# Bake the navigation geometry for each agent size from the same source geometry.
	# If required for performance this baking step could also be done on background threads.
	for mesh_item:NavigationMeshListItem in navigation_mesh_list_items:
		mesh_item.mesh = NavigationMesh.new()
		mesh_item.mesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
		mesh_item.mesh.geometry_collision_mask = collision_mask
		mesh_item.mesh.agent_height = mesh_item.agent_height
		mesh_item.mesh.agent_radius = mesh_item.agent_radius
		mesh_item.mesh.cell_height = 0.1
		mesh_item.mesh.cell_size = 0.1
		NavigationServer3D.bake_from_source_geometry_data(mesh_item.mesh, source_geometry_data)
		
		if mesh_item.mesh == null:
			printerr("nav mesh is null!")
		var mesh_polygon_count = mesh_item.mesh.get_polygon_count()
		if mesh_item.mesh.get_polygon_count() == 0:
			printerr("nav mesh has no polygons!")
		
		# Create different navigation maps on the NavigationServer.
		var navigation_map_rid:RID = NavigationServer3D.map_create()
		mesh_item.map_rid = navigation_map_rid
		# Set the new navigation maps as active.
		NavigationServer3D.map_set_active(navigation_map_rid, true)
		# Create a region for each map.
		var navigation_region_rid: RID = NavigationServer3D.region_create()
		mesh_item.region_rid = navigation_region_rid
		# Add the regions to the maps.
		NavigationServer3D.region_set_map(navigation_region_rid, navigation_map_rid)
		# Set navigation mesh for each region.
		NavigationServer3D.region_set_navigation_mesh(navigation_region_rid, mesh_item.mesh)
		EventBus.navigation_mesh_list_item_baked.emit(mesh_item)
		LevelManager.level_navigation_maps[mesh_item.name] = mesh_item
		if OS.is_debug_build():
			var filename = "user://"+mesh_item.name+".tres"
			var save_result := ResourceSaver.save(mesh_item.mesh,filename)
			if save_result != OK:
				pass
	NavigationServer3D.set_debug_enabled(true)

func get_navigation_mesh_list_item(mesh_name:String) -> NavigationMeshListItem:
	for item in navigation_mesh_list_items:
		if item.name == mesh_name:
			return item
	return null
