extends EnemyAction

@export var damage := 20

func perform_normal_action() -> void:
	# 在表世界不会使用此技能
	pass

func perform_flipped_action() -> void:
	_do_attack(damage * enemy.stats.damage_multiplier, true)

func _do_attack(attack_damage: int, is_flipped: bool) -> void:
	if not enemy or not target:
		return
	
	var actual_damage := 0
	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	var start := enemy.global_position
	var end := target.global_position + Vector2.RIGHT * 32
	var damage_effect := DamageEffect.new()
	var target_array: Array[Node] = [target]
	damage_effect.amount = attack_damage
	damage_effect.sound = sound
	
	tween.tween_property(enemy, "global_position", end, 0.3)
	
	tween.tween_interval(0.15)
	tween.tween_property(enemy, "global_position", start, 0.3)
	
	tween.finished.connect(
		func():
			Events.enemy_action_completed.emit(enemy)
	)

# 表世界不可执行
func is_performable_in_normal_world() -> bool:
	return false

# 里世界总是可执行
func is_performable_in_flipped_world() -> bool:
	return true

func update_intent_text() -> void:
	var player := target as Player
	if not player:
		return
	
	# 里世界伤害（考虑伤害倍率）
	var base_damage = damage * enemy.stats.damage_multiplier
	var modified_dmg := player.modifier_handler.get_modified_value(base_damage, Modifier.Type.DMG_TAKEN)
