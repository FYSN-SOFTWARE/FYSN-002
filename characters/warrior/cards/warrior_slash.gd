extends Card

var base_damage := 4


func get_default_tooltip() -> String:
	return tooltip_text % base_damage


func get_updated_tooltip(player_modifiers: ModifierHandler, enemy_modifiers: ModifierHandler) -> String:
	var modified_dmg := player_modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)

	if enemy_modifiers:
		modified_dmg = enemy_modifiers.get_modified_value(modified_dmg, Modifier.Type.DMG_TAKEN)
		
	return tooltip_text % modified_dmg


func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	var damage_effect := DamageEffect.new()
	damage_effect.amount = modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	damage_effect.sound = sound
	damage_effect.execute(targets)


# 新增反面效果
func _init():
	# 创建反面效果
	back_side = CardSide.new()
	back_side.id = "slash_back"
	back_side.type = Type.ATTACK
	back_side.cost = 1
	back_side.tooltip_text = "造成 [color=red]2[/color] 点伤害。如果目标有暴露状态，额外造成 [color=red]3[/color] 点伤害。"
	
