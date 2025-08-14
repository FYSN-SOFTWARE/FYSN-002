extends EnemyAction

@export var heal_amount := 6

func perform_action() -> void:
	if not enemy:
		return
	
	# 创建治疗效果
	var heal_effect := HealEffect.new()
	heal_effect.amount = heal_amount
	heal_effect.sound = sound
	heal_effect.execute([enemy])
	
	get_tree().create_timer(0.6, false).timeout.connect(
		func():
			Events.enemy_action_completed.emit(enemy)
	)
