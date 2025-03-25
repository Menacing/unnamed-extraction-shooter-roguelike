@tool
extends Node3D


@export_range(0.0,2.0,0.05) var range_factor:float = 1.4
@export_range(0.0,2.0,0.05) var energy_factor:float = 0.3
@export_tool_button("Create fake GI light") var create_fake_gi_light_action = create_fake_gi_light
func create_fake_gi_light():
	print("create fake gi light called")
	#check if parent is spot or omni light
	var parent_light = self.get_parent()
	#if omni
	
	if parent_light is OmniLight3D:
		print("parent light omni light")
		
		#check for existing light
		var fake_gi_light: OmniLight3D
		print("Children of node:", self.get_children())
		for child in self.get_children():
			if child is OmniLight3D:
				fake_gi_light = child
				print("using existing fake gi light")
				
				break
		if fake_gi_light == null:
			print("create new fake gi light")
			
			fake_gi_light = OmniLight3D.new()
			self.add_child(fake_gi_light, true)
			fake_gi_light.owner = get_tree().edited_scene_root
			
		#In the secondary OmniLight3D node, perform the following changes:
		fake_gi_light.omni_attenuation = parent_light.omni_attenuation
		fake_gi_light.distance_fade_begin = parent_light.distance_fade_begin
		fake_gi_light.distance_fade_enabled = parent_light.distance_fade_enabled
		fake_gi_light.distance_fade_length = parent_light.distance_fade_length
		fake_gi_light.distance_fade_shadow = parent_light.distance_fade_shadow
		fake_gi_light.light_bake_mode = parent_light.light_bake_mode
		fake_gi_light.light_color = parent_light.light_color
		
		#Increase the light's Range by 25-50%. This allows the secondary light to lighten what was previously not lit by the original light.
		fake_gi_light.omni_range = parent_light.omni_range * range_factor
		#Set Shadows to Off. This reduces the secondary light's performance burden while also allowing shaded areas to receive some lighting (which is what we want here).
		fake_gi_light.shadow_enabled = false
		#Set Energy to 10-40% of the original value. There is no "perfect" value, so experiment with various energy values depending on the light and its surroundings.
		fake_gi_light.light_energy = parent_light.light_energy * energy_factor
		#Set Specular to 0. Indirect lighting shouldn't emit visible specular lobes, so we need to disable specular lighting entirely for the secondary light.
		fake_gi_light.light_specular = 0.0
		
	#if spotlight
	elif parent_light is SpotLight3D:
		print("parent light spot light")
		#check for existing light
		var fake_gi_light: OmniLight3D
		print("Children of node:", self.get_children())
		for child in self.get_children():
			if child is OmniLight3D:
				fake_gi_light = child
				print("using existing fake gi light")
				break
		if fake_gi_light == null:
			print("create new fake gi light")
			fake_gi_light = OmniLight3D.new()
			self.add_child(fake_gi_light, true)
			fake_gi_light.owner = get_tree().edited_scene_root
			
		#In the secondary OmniLight3D node, perform the following changes:
		fake_gi_light.omni_attenuation = parent_light.spot_attenuation
		fake_gi_light.distance_fade_begin = parent_light.distance_fade_begin
		fake_gi_light.distance_fade_enabled = parent_light.distance_fade_enabled
		fake_gi_light.distance_fade_length = parent_light.distance_fade_length
		fake_gi_light.distance_fade_shadow = parent_light.distance_fade_shadow
		fake_gi_light.light_bake_mode = parent_light.light_bake_mode
		fake_gi_light.light_color = parent_light.light_color
		
		#Increase the light's Range by 25-50%. This allows the secondary light to lighten what was previously not lit by the original light.
		fake_gi_light.omni_range = parent_light.spot_range * range_factor
		#Set Shadows to Off. This reduces the secondary light's performance burden while also allowing shaded areas to receive some lighting (which is what we want here).
		fake_gi_light.shadow_enabled = false
		#Set Energy to 10-40% of the original value. There is no "perfect" value, so experiment with various energy values depending on the light and its surroundings.
		fake_gi_light.light_energy = parent_light.light_energy * energy_factor
		#Set Specular to 0. Indirect lighting shouldn't emit visible specular lobes, so we need to disable specular lighting entirely for the secondary light.
		fake_gi_light.light_specular = 0.0

		#Raycasting from a tool script is a mess. Maybe someday, till then just position these by hand
		##raycast along facing
		#var raycast_result = cast_ray()
		#print("raycast result: ", raycast_result)
		#if raycast_result:
			#fake_gi_light.global_position = raycast_result
		#else:
			#print("no collision found, removing fake gi light")
			#fake_gi_light.queue_free()
	pass
	#
#func cast_ray():
	#if Engine.is_editor_hint():
		##raycasting in the editor is a nightmare, just return self
		#return self.global_position
	#else:
		#if ray_cast_3d.is_colliding():
			#return ray_cast_3d.get_collision_point()
		#else:
			#return null


func _get_configuration_warnings():
	if self.get_parent() is OmniLight3D or self.get_parent() is SpotLight3D:
		return []
	else:
		return ["Component's parent must be OmniLight3D or SpotLight3D"]
		
#func _ready():
	##check for existing light
	#var fake_gi_light: OmniLight3D
	#for child in self.get_children():
		#if child is OmniLight3D:
			#fake_gi_light = child
			#break
	#if fake_gi_light == null:
		#create_fake_gi_light()
	
