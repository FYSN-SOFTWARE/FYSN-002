class_name HealEffect
extends Effect

var amount := 0


func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target is Enemy or target is Player:
			# 治疗目标，但不超过最大生命值
			target.stats.health += amount
			if target.stats.health > target.stats.max_health:
				target.stats.health = target.stats.max_health
			
			# 播放治疗音效
			SFXPlayer.play(sound)
			
			# 创建治疗粒子效果（如果项目中有）
			if target.has_method("show_heal_effect"):
				target.show_heal_effect(amount)
