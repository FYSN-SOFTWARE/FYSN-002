extends Card

var front_damage := 8
var back_san_damage := 2
var back_hit_count := 3
var hit_delay := 0.3  

func _ready():
	set_flipped(false)

func set_flipped(flipped: bool) -> void:
	is_flipped = flipped
	

	if is_flipped:
		target = Target.SINGLE_ENEMY  
		cost = 1  
	else:
		target = Target.SINGLE_ENEMY  
		cost = 1  
	

	super.set_flipped(flipped)

func get_default_tooltip() -> String:
	if is_flipped:
		return "[center]造成 [color=\"purple\"]%s[/color] 点san伤害 %s 次。[/center]" % [back_san_damage, back_hit_count]
	else:
		return "[center]造成 [color=\"ff0000\"]%s[/color] 点血量伤害。[/center]" % front_damage

func get_updated_tooltip(player_modifiers: ModifierHandler, enemy_modifiers: ModifierHandler) -> String:
	if is_flipped:
		var modified_dmg := player_modifiers.get_modified_value(back_san_damage, Modifier.Type.SAN_DMG_DEALT)
		if enemy_modifiers:
			modified_dmg = enemy_modifiers.get_modified_value(modified_dmg, Modifier.Type.SAN_DMG_TAKEN)
		return "[center]造成 [color=\"purple\"]%s[/color] 点san伤害 %s 次。[/center]" % [modified_dmg, back_hit_count]
	else:
		var modified_dmg := player_modifiers.get_modified_value(front_damage, Modifier.Type.DMG_DEALT)
		if enemy_modifiers:
			modified_dmg = enemy_modifiers.get_modified_value(modified_dmg, Modifier.Type.DMG_TAKEN)
		return "[center]造成 [color=\"ff0000\"]%s[/color] 点血量伤害。[/center]" % modified_dmg

func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	if is_flipped:
		_apply_multiple_san_damage(targets, modifiers)
	else:

		var damage_effect := DamageEffect.new()
		damage_effect.amount = modifiers.get_modified_value(front_damage, Modifier.Type.DMG_DEALT)
		damage_effect.receiver_modifier_type = Modifier.Type.DMG_TAKEN
		damage_effect.sound = sound
		damage_effect.execute(targets)

func _apply_multiple_san_damage(targets: Array[Node], modifiers: ModifierHandler) -> void:
	if targets.is_empty():
		return

	var scene_tree = targets[0].get_tree()
	if not scene_tree:
		return

	for i in back_hit_count:
		var damage_effect := DamageEffect.new()
		damage_effect.amount = modifiers.get_modified_value(back_san_damage, Modifier.Type.SAN_DMG_DEALT)
		damage_effect.receiver_modifier_type = Modifier.Type.SAN_DMG_TAKEN
		damage_effect.sound = sound
		damage_effect.execute(targets)
		
		if i < back_hit_count - 1:
			await scene_tree.create_timer(hit_delay).timeout

func play(targets: Array[Node], char_stats: CharacterStats, modifiers: ModifierHandler, play_twice: bool) -> void:
	Events.card_played.emit(self)
	
	if is_flipped:
		char_stats.soals -= cost  
	else:
		char_stats.mana -= cost
	
	if is_single_targeted():
		apply_effects(targets, modifiers)
		if play_twice:
			if not targets.is_empty():
				var scene_tree = targets[0].get_tree()
				if scene_tree:
					await scene_tree.process_frame
			apply_effects(targets, modifiers)
	else:
		var targets_array = _get_targets(targets)
		apply_effects(targets_array, modifiers)
		if play_twice:
			if not targets_array.is_empty():
				var scene_tree = targets_array[0].get_tree()
				if scene_tree:
					await scene_tree.process_frame
			apply_effects(targets_array, modifiers)
