extends Card

var front_block := 8
var back_san_damage := 5

func _ready():
	set_flipped(false)

func set_flipped(flipped: bool) -> void:
	is_flipped = flipped
	
	if is_flipped:
		target = Target.SINGLE_ENEMY
		cost = 1  
	else:
		target = Target.SELF 
		cost = 1  
	
	# 调用基类的翻转逻辑
	super.set_flipped(flipped)

func get_default_tooltip() -> String:
	if is_flipped:
		return "[center]造成 [color=\"purple\"]%s[/color] 点san伤害。[/center]" % back_san_damage
	else:
		return "[center]获得 [color=\"0044ff\"]%s[/color] 点护盾。[/center]" % front_block

func get_updated_tooltip(player_modifiers: ModifierHandler, enemy_modifiers: ModifierHandler) -> String:
	if is_flipped:
		var modified_dmg := player_modifiers.get_modified_value(back_san_damage, Modifier.Type.SAN_DMG_DEALT)
		if enemy_modifiers:
			modified_dmg = enemy_modifiers.get_modified_value(modified_dmg, Modifier.Type.SAN_DMG_TAKEN)
		return "[center]造成 [color=\"purple\"]%s[/color] 点san伤害。[/center]" % modified_dmg
	else:
		var modified_block := player_modifiers.get_modified_value(front_block, Modifier.Type.DMG_DEALT)
		return "[center]获得 [color=\"0044ff\"]%s[/color] 点护盾。[/center]" % modified_block

func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	if is_flipped:
		var damage_effect := DamageEffect.new()
		damage_effect.amount = modifiers.get_modified_value(back_san_damage, Modifier.Type.SAN_DMG_DEALT)
		damage_effect.receiver_modifier_type = Modifier.Type.SAN_DMG_TAKEN
		damage_effect.sound = sound
		damage_effect.execute(targets)
	else:
		var block_effect := BlockEffect.new()
		block_effect.amount = modifiers.get_modified_value(front_block, Modifier.Type.DMG_DEALT)
		block_effect.sound = sound
		block_effect.execute(targets)

func play(targets: Array[Node], char_stats: CharacterStats, modifiers: ModifierHandler, play_twice: bool) -> void:
	Events.card_played.emit(self)
	
	if is_flipped:
		char_stats.soals -= cost  
	else:
		char_stats.mana -= cost
	
	if is_single_targeted():
		apply_effects(targets, modifiers)
		if play_twice:
			apply_effects(targets, modifiers)
	else:
		apply_effects(_get_targets(targets), modifiers)
		if play_twice:
			apply_effects(_get_targets(targets), modifiers)
