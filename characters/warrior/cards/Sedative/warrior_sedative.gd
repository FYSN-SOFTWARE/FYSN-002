extends Card

var front_san_heal := 24
var front_san_penalty := 24
var signal_connected := false

func set_flipped(flipped: bool) -> void:
	is_flipped = flipped
	target = Target.ALL_ENEMIES if flipped else Target.SELF
	cost = 2 if flipped else 1
	super.set_flipped(flipped)
	
	# 在这里连接信号，确保卡牌已经初始化
	_ensure_signal_connected()

func _ensure_signal_connected():
	if not signal_connected and Events:
		Events.world_flipped_with_hand.connect(_on_world_flipped_with_hand)
		signal_connected = true

func _on_world_flipped_with_hand(into_back_world: bool, hand_cards: Array[Card]):
	# 当进入里世界时，检查该卡牌是否在手牌中
	if into_back_world and hand_cards.has(self):
		_apply_world_flip_penalty()

func _apply_world_flip_penalty():
	# 直接触发san值伤害事件，让系统处理
	Events.player_san_damage_taken.emit(front_san_penalty)

func get_default_tooltip() -> String:
	if is_flipped:
		return "[center]造成等同于角色当前san值的san伤害给所有敌人。\n使用后退出里世界，souls归零。[/center]"
	else:
		return "[center]恢复 [color=\"purple\"]%s[/color] 点san值。\n[color=\"red\"]进入里世界时若在手牌中会扣除%s点san值。[/color][/center]" % [front_san_heal, front_san_penalty]

func get_updated_tooltip(player_modifiers: ModifierHandler, enemy_modifiers: ModifierHandler) -> String:
	return get_default_tooltip()

func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	if targets.is_empty():
		return
		
	if is_flipped:
		# 反面：造成san上限-当前san值的san伤害给所有敌人
		var player_nodes = targets[0].get_tree().get_nodes_in_group("player")
		if not player_nodes.is_empty() and player_nodes[0].stats:
			var max_san = player_nodes[0].stats.max_san
			var current_san = player_nodes[0].stats.san
			var damage_amount = max(0, max_san - current_san)  # 确保伤害不为负数
			
			if damage_amount > 0:
				var damage_effect := DamageEffect.new()
				damage_effect.amount = modifiers.get_modified_value(damage_amount, Modifier.Type.SAN_DMG_DEALT)
				damage_effect.receiver_modifier_type = Modifier.Type.SAN_DMG_TAKEN
				damage_effect.sound = sound
				damage_effect.execute(targets)
	else:
		# 正面：恢复san值给玩家
		for target in targets:
			if target and target.stats:
				target.stats.san = min(target.stats.max_san, target.stats.san + front_san_heal)

func play(targets: Array[Node], char_stats: CharacterStats, modifiers: ModifierHandler, play_twice: bool) -> void:
	_ensure_signal_connected()
	
	Events.card_played.emit(self)
	
	if is_flipped:
		char_stats.soals -= cost
		
		if is_single_targeted():
			apply_effects(targets, modifiers)
			if play_twice:
				apply_effects(targets, modifiers)
		else:
			apply_effects(_get_targets(targets), modifiers)
			if play_twice:
				apply_effects(_get_targets(targets), modifiers)

		Events.world_flipped.emit(false)
		Global.is_world_flipped = false
		char_stats.soals = 0
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

func _delayed_world_exit(char_stats: CharacterStats):
	_exit_back_world.call_deferred(char_stats)

func _exit_back_world(char_stats: CharacterStats):
	Events.world_flipped.emit(false)
	char_stats.soals = 0
	_ensure_ui_updated.call_deferred()

func _ensure_ui_updated():
	Events.player_turn_start.emit()  
