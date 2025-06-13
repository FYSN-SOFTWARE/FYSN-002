class_name Effect
extends Resource

enum TriggerMethod{
	NONE,
	INTOBACKWORD,
	OUTBACKWORD,
	CARDACTION,
	TRANCAREA,
	OTHER
}
enum CostType{
	USEENERGY,
	USESOALS,
	NONE,
	CANTUSE,
	TRANSCARD,
	PAYHEALTH,
	PAYSAN,
	OTHER
}
enum CardArea{NONE,DRAWDECK,HAND,GRAVEYARD,EXILEPILE}
enum Target {SELFONE, SINGLE_ENEMY, ALL_ENEMIES, EVERYONE,SOMEONE}
enum EffectType{HEALTHDEMAGE,SANDEMAGE,BLOCK,HEALTHHEAL,SANHEAL,TRANSCARD,BUFF,OTHER}

@export var triggerMethod:TriggerMethod
@export var costType:CostType
@export var target:Target
@export var effectType:EffectType
@export var effectValue:int
@export var can_action_area:CardArea
@export var cost_start_area:CardArea
@export var cost_end_area:CardArea
@export var effect_start_area:CardArea
@export var effect_end_area:CardArea

var sound: AudioStream#不要

func _connectsignal() -> void:
	match triggerMethod:
		TriggerMethod.NONE:
			pass
		TriggerMethod.INTOBACKWORD:
			Events.intobackword.connect(cost)
		TriggerMethod.OUTBACKWORD:
			Events.outbackword.connect(cost)
		TriggerMethod.CARDACTION:
			pass
		TriggerMethod.TRANCAREA:
			pass
	pass

func _initialize() -> void:
	match can_action_area:
		CardArea.NONE:
			pass
		CardArea.DRAWDECK:
			pass
		CardArea.HAND:
			pass
		CardArea.GRAVEYARD:
			pass
		CardArea.EXILEPILE:
			pass
	pass

func cost() -> void:
	pass

func execute(_targets: Array[Node]) -> void:
	pass
