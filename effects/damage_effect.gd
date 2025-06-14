class_name DamageEffect
extends Effect

var amount := 0
var receiver_modifier_type := Modifier.Type.DMG_TAKEN


func execute(targets: Array[Node]) -> void:
	for target in targets:
		if target is Enemy or target is Player:
			target.take_damage(int(amount), receiver_modifier_type)
			SFXPlayer.play(sound)
