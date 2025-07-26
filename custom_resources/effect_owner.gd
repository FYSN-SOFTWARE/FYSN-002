extends Resource
class_name EffectOwner

@export var effects: Array[Effect]

var can_use: bool


func check_action() -> bool:
	if(can_use):
		action()
	return can_use

func action() -> void:
	effects[0].action()

func over_use() -> void:
	can_use = false
	pass

func turn_to_use() -> void:
	can_use = true
	pass
