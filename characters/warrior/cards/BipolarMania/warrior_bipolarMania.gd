extends Card

func set_flipped(flipped: bool) -> void:
	is_flipped = flipped
	target = Target.ALL_ENEMIES if flipped else Target.EVERYONE
	cost = 1 if flipped else 2
	super.set_flipped(flipped)

func get_default_tooltip() -> String:
	if is_flipped:
		return "[center]对所有敌人造成10点san伤害。[/center]"
	else:
		return "[center]为所有对象施加3层易伤。[/center]"

func get_updated_tooltip(player_modifiers: ModifierHandler, enemy_modifiers: ModifierHandler) -> String:
	return get_default_tooltip()

func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	if targets.is_empty():
		return
		
	if is_flipped:
		# 反面：对所有敌人造成10点san伤害
		var damage_effect := DamageEffect.new()
		damage_effect.amount = 10
		damage_effect.receiver_modifier_type = Modifier.Type.SAN_DMG_TAKEN
		damage_effect.sound = sound
		damage_effect.execute(targets)
	else:
		# 正面：为所有对象施加3层易伤
		var exposed_status = preload("res://statuses/exposed.tres").duplicate()
		exposed_status.duration = 3
		
		var status_effect := StatusEffect.new()
		status_effect.status = exposed_status
		status_effect.execute(targets)

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
