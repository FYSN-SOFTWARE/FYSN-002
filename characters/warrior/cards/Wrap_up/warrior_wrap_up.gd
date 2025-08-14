extends Card

var front_block := 12
var back_san_heal := 3

func _ready():
	set_flipped(false)

func set_flipped(flipped: bool) -> void:
	is_flipped = flipped
	
	if is_flipped:
		target = Target.SELF
		cost = 0  
	else:
		target = Target.SELF
		cost = 2 
	
	super.set_flipped(flipped)

func get_default_tooltip() -> String:
	if is_flipped:
		return "[center]恢复 [color=\"purple\"]%s[/color] 点san值。[/center]" % back_san_heal
	else:
		return "[center]获得 [color=\"0044ff\"]%s[/color] 点护盾。[/center]" % front_block

func get_updated_tooltip(player_modifiers: ModifierHandler, enemy_modifiers: ModifierHandler) -> String:
	if is_flipped:
		return "[center]恢复 [color=\"purple\"]%s[/color] 点san值。[/center]" % back_san_heal
	else:
		var modified_block := player_modifiers.get_modified_value(front_block, Modifier.Type.DMG_DEALT)
		return "[center]获得 [color=\"0044ff\"]%s[/color] 点护盾。[/center]" % modified_block

func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	if is_flipped:
		var san_heal_effect := SanHealEffect.new()
		san_heal_effect.amount = back_san_heal
		san_heal_effect.sound = sound
		san_heal_effect.execute(targets)
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
