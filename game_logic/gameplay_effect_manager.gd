extends Node

func _ready():
	EventBus.create_effect.connect(_on_create_effect)
	EventBus.remove_effect.connect(_on_remove_effect)

func _on_create_effect(actor_id:int, gameplay_effect:GameplayEffect):
	for effect_list in gameplay_effect.effect_lists:
		for effect in effect_list.effects_list:
			var mod_stat:ModifiableStat = effect_list.effect_target_node[effect.modifiable_stat_name]
			for stat_mod in effect.stat_modifiers:
				mod_stat.add_modifier(stat_mod)
	pass
	
func _on_remove_effect(actor_id:int, gameplay_effect:GameplayEffect):
	for effect_list in gameplay_effect.effect_lists:
		for effect in effect_list.effects_list:
			var mod_stat:ModifiableStat = effect_list.effect_target_node[effect.modifiable_stat_name]
			for stat_mod in effect.stat_modifiers:
				mod_stat.remove_modifier(stat_mod)
