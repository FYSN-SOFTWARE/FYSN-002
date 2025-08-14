class_name EnemyStats
extends Stats

@export var ai: PackedScene
@export var damage_multiplier: float = 1.5

func set_san(value: int) -> void:
	san = clampi(value, 0, max_san)
	stats_changed.emit()

func take_san_damage(damage: int) -> void:
	set_san(san - damage)
