@tool
extends Node

@export_tool_button("Create fake GI light") var create_fake_gi_light_action = create_fake_gi_light
func create_fake_gi_light():
	#check if parent is spot or omni light
	
	#if omni
	#In the secondary OmniLight3D node, perform the following changes:
#
	#Increase the light's Range by 25-50%. This allows the secondary light to lighten what was previously not lit by the original light.
#
	#Set Shadows to Off. This reduces the secondary light's performance burden while also allowing shaded areas to receive some lighting (which is what we want here).
#
	#Set Energy to 10-40% of the original value. There is no "perfect" value, so experiment with various energy values depending on the light and its surroundings.
#
	#Set Specular to 0. Indirect lighting shouldn't emit visible specular lobes, so we need to disable specular lighting entirely for the secondary light.

	#if spotlight
	#raycast along facing
	#do all of above

	pass
