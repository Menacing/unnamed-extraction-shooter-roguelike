extends TextureRect
class_name GameplayEffectControl

#@onready var texture_control:TextureRect = $"."


func set_effect_icon(icon:Texture2D):
	texture = icon
