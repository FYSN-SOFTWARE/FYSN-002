class_name Effect
extends Resource

enum TriggerMethod{
	NONE,
	INTOBACKWORLD,
	OUTBACKWORLD,
	CARDACTION,
	TRANSCAREA,
	BATTLESTARTE,
	TURNSTARTE,
	TURNEND,
	OTHER
}
enum CostType{
	UseEnergy,
	UseSoals,
	None,
	CantUse,
	TransCard,
	PayHealth,
	PaySan,
	Other
}
enum CardArea{NONE,DRAWDECK,HAND,GRAVEYARD,EXILEPILE}
enum Target {SELF, SELFONE, SINGLE_ENEMY, ALL_ENEMIES, EVERYONE,SOMEONE}
enum EffectType{HEALTHDEMAGE,SANDEMAGE,BLOCK,HEALTHHEAL,SANHEAL,TRANSCARD,BUFF,COUNTER,OTHER,UPGRADE}
enum EffectTager{Once,Forever}

@export var triggerMethod:TriggerMethod
@export var costType:CostType
@export var costint: int
@export var se_costType:CostType
@export var se_costint: int
@export var target:Target
@export var effectType:EffectType
@export var effectValue:int
@export var effectTager:EffectTager
@export var can_action_area:CardArea
@export var get_target_start_area:CardArea
@export var get_target_end_area:CardArea
@export var effect_start_area:CardArea
@export var effect_end_area:CardArea
@export var follow_effect:Effect
@export var effect_owner:EffectOwner
#@export var 

var use_cost: bool
var targets: Array[Node] = []

var _corrnentarea: CardArea
var corrnentarea: CardArea:
	get:
		return _corrnentarea
	set(value):
		_corrnentarea = value
		_initialize()

var sound: AudioStream#不要

func _connectsignal() -> void:
	match triggerMethod:
		TriggerMethod.NONE:
			pass
		TriggerMethod.INTOBACKWORLD:
			Events.world_flipped.connect(func(into:bool):if(into == true):get_target())
		TriggerMethod.OUTBACKWORLD:
			Events.world_flipped.connect(func(into:bool):if(into == false):get_target())
		TriggerMethod.CARDACTION:
			Events.cardaction.connect(card_action_signal)
		TriggerMethod.TRANSCAREA:
			Events.transcard.connect(transcard_signalc)
		TriggerMethod.BATTLESTARTE:
			Events.battle_starte.connect(get_target)
		TriggerMethod.TURNSTARTE:
			Events.player_turn_start.connect(get_target)
		TriggerMethod.TURNEND:
			Events.player_turn_ended.connect(get_target)
		TriggerMethod.OTHER:
			other_signal()
	pass

func _initialize() -> void:
	if(can_action_area == _corrnentarea):
		_connectsignal()


func get_target() -> void:
	
	pass

func cost() -> void:
	if not use_cost:
		use_cost = true
		action()
		return
	match costType:
		CostType.None:
			pass
		CostType.UseEnergy:
			Battle.battle.mana.mana -= costint
		CostType.UseSoals:
			Battle.battle.mana.soals -= costint
		CostType.CantUse:
			return
		CostType.TransCard:
			pass
		CostType.PayHealth:
			pass
		CostType.PaySan:
			pass
		CostType.Other:
			other_costtype()
	match se_costType:
		CostType.None:
			pass
		CostType.UseEnergy:
			Battle.battle.mana.mana -= costint
		CostType.UseSoals:
			Battle.battle.mana.soals -= costint
		CostType.CantUse:
			return
		CostType.TransCard:
			pass
		CostType.PayHealth:
			pass
		CostType.PaySan:
			pass
		CostType.Other:
			other_costtype()
	action()

func other_costtype() -> void:
	pass

func card_action_signal(card: Card) -> void:
	pass

func transcard_signalc(areafrom: Effect.CardArea, areato: Effect.CardArea) -> void:
	pass

func other_signal() -> void:
	pass

func action() -> void:
	pass

func execute(_targets: Array[Node]) -> void:
	pass
