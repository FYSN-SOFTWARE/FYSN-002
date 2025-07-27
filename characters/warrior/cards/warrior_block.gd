extends Card

var base_block := 5


func get_default_tooltip() -> String:
	return tooltip_text % base_block


func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text % base_block


func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var block_effect := BlockEffect.new()
	block_effect.amount = base_block
	block_effect.sound = sound
	block_effect.execute(targets)


# 新增反面效果
func _init():
	back_side = CardSide.new()
	back_side.id = "block_back"
	back_side.type = Type.SKILL
	back_side.cost = 1
	back_side.tooltip_text = "获得 [color=blue]4[/color] 点格挡。每有一层肌肉，额外获得 [color=blue]2[/color] 点格挡。"
	
