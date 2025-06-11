class_name EnemyAction
extends Node

enum Type {CONDITIONAL, CHANCE_BASED}

@export var intent: Intent
@export var sound: AudioStream
@export var type: Type
@export_range(0.0, 10.0) var chance_weight := 0.0

@onready var accumulated_weight := 0.0

var enemy: Enemy
var target: Node2D


func is_performable() -> bool:
	# 在里世界中改变行为条件
	if enemy and enemy.is_flipped:
		return is_performable_in_flipped_world()
	return is_performable_in_normal_world()


func perform_action() -> void:
	if enemy and enemy.is_flipped:
		perform_flipped_action()
	else:
		perform_normal_action()


func update_intent_text() -> void:
	intent.current_text = intent.base_text


# 正常世界的行为条件
func is_performable_in_normal_world() -> bool:
	return false

# 里世界的行为条件
func is_performable_in_flipped_world() -> bool:
	return false

func perform_normal_action() -> void:
	# 正常世界的攻击逻辑
	perform_base_action(intent.damage)

func perform_flipped_action() -> void:
	# 里世界的特殊攻击逻辑
	var damage_multiplier := 1.5
	perform_base_action(intent.damage * damage_multiplier)

func perform_base_action(damage_amount: float) -> void:
	if not enemy or not target:
		return
	
	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	var start := enemy.global_position
	var end := target.global_position + Vector2.RIGHT * 32
	
	SFXPlayer.play(sound)
	tween.tween_property(enemy, "global_position", end, 0.2)
	tween.tween_callback(
		func():
			target.take_damage(damage_amount, Modifier.Type.DMG_TAKEN)
	)
	tween.tween_property(enemy, "global_position", start, 0.2)
	
	Events.enemy_action_completed.emit(enemy)
