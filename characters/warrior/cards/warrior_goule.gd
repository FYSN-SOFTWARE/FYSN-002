extends Card

var front_damage := 6
var back_damage := 10

func _ready():
	set_flipped(false)

func get_default_tooltip() -> String:
	if is_flipped:
		return "[center]消耗1souls，造成 [color=\"purple\"]%s[/color] 点san伤害。[/center]" % back_damage
	else:
		return "[center]造成 [color=\"ff0000\"]%s[/color] 点血量伤害。[/center]" % front_damage

func get_updated_tooltip(player_modifiers: ModifierHandler, enemy_modifiers: ModifierHandler) -> String:
	if is_flipped:
		var modified_dmg := player_modifiers.get_modified_value(back_damage, Modifier.Type.SAN_DMG_DEALT)
		if enemy_modifiers:
			modified_dmg = enemy_modifiers.get_modified_value(modified_dmg, Modifier.Type.SAN_DMG_TAKEN)
		return "[center]消耗1souls，造成 [color=\"purple\"]%s[/color] 点san伤害。[/center]" % modified_dmg
	else:
		var modified_dmg := player_modifiers.get_modified_value(front_damage, Modifier.Type.DMG_DEALT)
		if enemy_modifiers:
			modified_dmg = enemy_modifiers.get_modified_value(modified_dmg, Modifier.Type.DMG_TAKEN)
		return "[center]造成 [color=\"ff0000\"]%s[/color] 点血量伤害。[/center]" % modified_dmg

func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	var damage_effect := DamageEffect.new()
	damage_effect.sound = sound
	
	if is_flipped:
		damage_effect.amount = modifiers.get_modified_value(back_damage, Modifier.Type.SAN_DMG_DEALT)
		damage_effect.receiver_modifier_type = Modifier.Type.SAN_DMG_TAKEN
	else:
		damage_effect.amount = modifiers.get_modified_value(front_damage, Modifier.Type.DMG_DEALT)
		damage_effect.receiver_modifier_type = Modifier.Type.DMG_TAKEN
	
	damage_effect.execute(targets)


func play(targets: Array[Node], char_stats: CharacterStats, modifiers: ModifierHandler,bool) -> void:
	Events.card_played.emit(self)
	
	if is_flipped:
		char_stats.soals -= cost  
	else:
		# 正面消耗mana
		char_stats.mana -= cost
	
	if is_single_targeted():
		apply_effects(targets, modifiers)
	else:
		apply_effects(_get_targets(targets), modifiers)
