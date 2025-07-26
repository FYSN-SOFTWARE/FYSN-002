class_name SoulUI
extends Panel

@export var char_stats: CharacterStats : set = _set_char_stats

@onready var soul_label: Label = $SoulLabel

func _set_char_stats(value: CharacterStats) -> void:
	char_stats = value
	
	if not char_stats.stats_changed.is_connected(_on_stats_changed):
		char_stats.stats_changed.connect(_on_stats_changed)

	if not is_node_ready():
		await ready

	_on_stats_changed()

func _on_stats_changed() -> void:
	soul_label.text = "%s/%s" % [char_stats.soals, char_stats.max_soals]
