extends HBoxContainer
class_name GameplayEffectListItemDisplay

@onready var _stat_label:Label = $StatLabel
@onready var _value_label:Label = $ValueLabel

var gameplay_list_item:GameplayEffectListItem

func _ready():
	if gameplay_list_item:
		_stat_label.text = gameplay_list_item.modifiable_stat_display_name
		var additive_part = 0.0
		var multiplicitive_part = 1.0
		for stat_mod in gameplay_list_item.stat_modifiers:
			if stat_mod.operation == stat_mod.Operation.ADD:
				additive_part += stat_mod.value
			elif stat_mod.operation == stat_mod.Operation.MUL:
				multiplicitive_part += stat_mod.value
		
		var value_text = "(BASE"
		if additive_part > 0:
			value_text += " + " + str(additive_part) + ")"
		elif additive_part < 0:
			value_text += " - " + str(abs(additive_part)) + ")"
		
		value_text += " x " + str(multiplicitive_part)
		_value_label.text = value_text
