# meta-name: EnemyAction
# meta-description: An action which can be performed by an enemy during its turn.
extends EnemyAction


func perform_action() -> void:
	if enemy.is_flipped:
		perform_flipped_action()
	else:
		perform_normal_action()
	
	if not enemy or not target:
		return
	
	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	var start := enemy.global_position
	var end := target.global_position + Vector2.RIGHT * 32
	
	SFXPlayer.play(sound)

	Events.enemy_action_completed.emit(enemy)


# If the enemy has dynamic intent text you can override the base behaviour here
# e.g. for attack actions, the Player's DMG TAKEN modifier modifies the resulting damage number.
func update_intent_text() -> void:
	var player := target as Player
	if not player:
		return
	
	var modified_dmg := player.modifier_handler.get_modified_value(6, Modifier.Type.DMG_TAKEN)
	intent.current_text = intent.base_text % modified_dmg

# 覆盖父类方法
func is_performable_in_normal_world() -> bool:
	# 正常世界的条件逻辑
	return super()

func is_performable_in_flipped_world() -> bool:
	# 里世界的特殊条件逻辑
	# 例如：在里世界中更频繁地使用特殊攻击
	return RNG.instance.randf() < 0.8

func perform_normal_action() -> void:
	# 正常世界的攻击逻辑
	perform_base_action(intent.damage)

func perform_flipped_action() -> void:
	# 里世界的特殊攻击逻辑
	var damage_multiplier := 1.5
	perform_base_action(intent.damage * damage_multiplier)

func perform_base_action(damage_amount: float) -> void:
	if not enemy or not target:
		return
	
	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	var start := enemy.global_position
	var end := target.global_position + Vector2.RIGHT * 32
	
	SFXPlayer.play(sound)
	tween.tween_property(enemy, "global_position", end, 0.2)
	tween.tween_callback(
		func():
			target.take_damage(damage_amount, Modifier.Type.DMG_TAKEN)
	)
	tween.tween_property(enemy, "global_position", start, 0.2)
	
	Events.enemy_action_completed.emit(enemy)
