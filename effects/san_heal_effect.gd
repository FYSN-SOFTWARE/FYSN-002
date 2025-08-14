class_name SanHealEffect
extends Effect

var amount := 0

func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target is Player:
			target.stats.san = min(target.stats.max_san, target.stats.san + amount)
			#SFXPlayer.play(sound)
