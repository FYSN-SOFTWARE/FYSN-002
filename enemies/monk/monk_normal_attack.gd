extends EnemyAction

@export var damage := 5

func perform_normal_action() -> void:
	_do_attack(damage, false)

func perform_flipped_action() -> void:
	# 在里世界不会使用此技能
	pass

func _do_attack(attack_damage: int, is_flipped: bool) -> void:
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
	
	tween.finished.connect(
		func():
			Events.enemy_action_completed.emit(enemy)
	)

# 表世界总是可执行
func is_performable_in_normal_world() -> bool:
	return true

# 里世界不可执行
func is_performable_in_flipped_world() -> bool:
	return false

func update_intent_text() -> void:
	var player := target as Player
	if not player:
		return
	
	# 表世界伤害
	var base_damage = damage
	var modified_dmg := player.modifier_handler.get_modified_value(base_damage, Modifier.Type.DMG_TAKEN)
