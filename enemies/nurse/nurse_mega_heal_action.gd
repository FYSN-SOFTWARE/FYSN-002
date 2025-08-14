extends EnemyAction

@export var mega_heal_amount := 20
@export var hp_threshold := 15

var already_used := false

func is_performable() -> bool:
	if not enemy or already_used:
		return false
	
	return enemy.stats.health <= hp_threshold

func perform_action() -> void:
	if not enemy:
		return
	
	# 创建强力治疗效果
	var heal_effect := HealEffect.new()
	heal_effect.amount = mega_heal_amount
	heal_effect.sound = sound
	heal_effect.execute([enemy])
	already_used = true
	
	get_tree().create_timer(0.6, false).timeout.connect(
		func():
			Events.enemy_action_completed.emit(enemy)
	)
