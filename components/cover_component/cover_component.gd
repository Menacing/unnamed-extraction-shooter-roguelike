@tool
extends Node3D
class_name CoverComponent

#func _ready() -> void:
	#create_cover_points()

@export var level_node:Node3D
@export var navigation_mesh:NavigationMesh

@export_tool_button("Generate Cover Points", "Callable") var generate_cover_action = create_cover_points

var edges:Dictionary[String, int] = {}

func create_cover_points():
	print("deleting previous children")
	
	for child in self.get_children():
		child.queue_free()
	
	print("Generating cover points")
	
	if navigation_mesh and level_node:
		var vertices:Array[Vector3] 
		vertices.assign(navigation_mesh.get_vertices())
		edges = {}
		
		for i in navigation_mesh.get_polygon_count():
			var polygon_vertexs:Array[Vector3] = []
			var vertext_indexes :Array[int]
			vertext_indexes.assign(navigation_mesh.get_polygon(i))
			for vert_index in vertext_indexes:
				polygon_vertexs.append(vertices[vert_index])
		
			for j in polygon_vertexs.size():
				var start_point:Vector3 = polygon_vertexs[j]
				var end_point:Vector3
				if j != polygon_vertexs.size() - 1:
					end_point = polygon_vertexs[j+1]
					pass
				# if last element, wrap around
				else:
					end_point = polygon_vertexs[0]
				
				var nmek:String = create_edge_key(start_point, end_point)
				var nmek_r:String = create_edge_key(end_point, start_point)
				if edges.has(nmek):
					edges[nmek] += 1
				elif edges.has(nmek_r):
					edges[nmek_r] += 1
				else:
					edges[nmek] = 1
			
			
		var boundary_keys:Array[String] = []
		for key in edges.keys():
			if edges[key] == 1:
				boundary_keys.append(key)
				
		
		for key in boundary_keys:
			var split_key = key.split("*")
			var start_point = Helpers.string_to_vector3(split_key[0])
			var end_point = Helpers.string_to_vector3(split_key[1])
			
			var section_length = start_point.distance_to(end_point)
			
			#put a cover point at the mid point if the section is short
			if section_length < 2.0:
				var midpoint = start_point.lerp(end_point, 0.5)
				
				var cover_point:Marker3D = Marker3D.new()
				self.add_child(cover_point)
				cover_point.owner = get_tree().edited_scene_root
				cover_point.global_position = midpoint
				cover_point.add_to_group("cover_point", true)
			else:

				var direction = (end_point - start_point).normalized()
				var steps = int(section_length / 2.0)
				for i in steps:
					var cover_point:Marker3D = Marker3D.new()
					self.add_child(cover_point)
					cover_point.owner = get_tree().edited_scene_root
					cover_point.global_position = start_point + direction * (i * 2.0)
					cover_point.add_to_group("cover_point", true)
		pass
	else:
		printerr("NO LEVEL NODE OR NAV MESH DATA SET")


static func create_edge_key(start:Vector3, end:Vector3) -> String:
	return str(start)+ "*" + str(end)
	
