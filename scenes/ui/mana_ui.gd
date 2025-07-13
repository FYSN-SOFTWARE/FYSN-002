class_name ManaUI
extends Panel

@export var char_stats: CharacterStats : set = _set_char_stats

@onready var mana_label: Label = $ManaLabel
@onready var san_label: Label = $SanLabel

var mana : int:
	set(value):
		mana = value
		text_change()
var max_mana : int:
	set(value):
		max_mana = value
		text_change()
var soals : int:
	set(value):
		soals = value
		text_change()
var max_soals : int:
	set(value):
		max_soals = value
		text_change()
var start_soals : int:
	set(value):
		start_soals = value

func _ready() -> void:
	char_stats = Battle.battle.char_stats
	pass

func _set_char_stats(value: CharacterStats) -> void:
	char_stats = value
	max_mana = char_stats.start_max_mana
	start_soals = char_stats.start_soals
	max_soals = char_stats.start_max_soals
	text_change()
	Events.battle_started.connect(battle_start_handler)
	Events.player_turn_start.connect(turn_start_handler)

func battle_start_handler() -> void:
	soals = start_soals
	pass

func  turn_start_handler() -> void:
	mana = max_mana
	pass

func text_change() -> void:
	mana_label.text = "%s/%s" % [mana, max_mana]
	san_label.text = "%s/%s" % [soals, max_soals]
