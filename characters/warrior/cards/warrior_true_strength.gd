extends Card

const TRUE_STRENGTH_FORM_STATUS = preload("res://statuses/true_strength_form.tres")


func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var status_effect := StatusEffect.new()
	var true_strength := TRUE_STRENGTH_FORM_STATUS.duplicate()
	status_effect.status = true_strength
	status_effect.execute(targets)


# 新增反面效果
func _init():
	back_side = CardSide.new()
	back_side.id = "true_strength_back"
	back_side.type = Type.POWER
	back_side.cost = 2
	back_side.tooltip_text = "获得 [color=gold]2[/color] 层肌肉。在里世界时，每回合额外获得 [color=gold]1[/color] 层肌肉。"
