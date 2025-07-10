class_name ManaUI
extends Panel

@export var char_stats: CharacterStats : set = _set_char_stats

@onready var mana_label: Label = $ManaLabel
@onready var san_label: Label = $SanLabel

var mana : int 
var max_mana : int
var soals : int
var max_soals : int

func _set_char_stats(value: CharacterStats) -> void:
	char_stats = value


func text_change() -> void:
	mana_label.text = "%s/%s" % [mana, max_mana]
	san_label.text = "%s/%s" % [soals, max_soals]
