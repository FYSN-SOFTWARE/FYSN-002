extends EnemyAction

@export var damage := 7

func perform_normal_action() -> void:
	_do_attack(damage)

func perform_flipped_action() -> void:
	# 里世界伤害加成
	var flipped_damage = damage * enemy.stats.damage_multiplier
	_do_attack(flipped_damage)

func _do_attack(attack_damage: int) -> void:
	if not enemy or not target:
		return
	
	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	var start := enemy.global_position
	var end := target.global_position + Vector2.RIGHT * 32
	var damage_effect := DamageEffect.new()
	var target_array: Array[Node] = [target]
	damage_effect.amount = attack_damage
	damage_effect.sound = sound
	
	tween.tween_property(enemy, "global_position", end, 0.4)
	tween.tween_callback(damage_effect.execute.bind(target_array))
	tween.tween_interval(0.25)
	tween.tween_property(enemy, "global_position", start, 0.4)
	
	tween.finished.connect(
		func():
			Events.enemy_action_completed.emit(enemy)
	)


func update_intent_text() -> void:
	var player := target as Player
	if not player:
		return
	
	# 考虑里世界伤害加成
	var base_damage = damage
	if enemy and enemy.is_flipped:
		base_damage *= enemy.stats.damage_multiplier
	
	var modified_dmg := player.modifier_handler.get_modified_value(base_damage, Modifier.Type.DMG_TAKEN)
	intent.current_text = intent.base_text % modified_dmg
