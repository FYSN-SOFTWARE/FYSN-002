class_name Stats
extends Resource

signal stats_changed

@export var max_health := 1 : set = set_max_health
@export var max_san : int
@export var art: Texture

var health: int : set = set_health
var san: int : set = set_san
var block: int : set = set_block


func set_health(value : int) -> void:
	health = clampi(value, 0, max_health)
	stats_changed.emit()

func set_san(value : int) -> void:
	san = clampi(value, 0, max_san)
	stats_changed.emit()

func set_max_health(value : int) -> void:
	var diff := value - max_health
	max_health = value
	
	if diff > 0:
		health += diff
	elif health > max_health:
		health = max_health
	
	stats_changed.emit()


func set_max_san(value : int) -> void:
	var diff := value - max_san
	max_san = value
	
	if diff > 0:
		san += diff
	elif san > max_san:
		san = max_san
	
	stats_changed.emit()


func set_block(value : int) -> void:
	block = clampi(value, 0, 999)
	stats_changed.emit()


func take_damage(damage : int) -> void:
	if damage <= 0:
		return
	var initial_damage = damage
	damage = clampi(damage - block, 0, damage)
	block = clampi(block - initial_damage, 0, block)
	health -= damage


# 添加处理精神伤害的方法
func take_li_damage(damage: int) -> void:
	if damage <= 0:
		return
	san = clampi(san - damage, 0, max_san)


func heal(amount : int) -> void:
	health += amount


func create_instance() -> Resource:
	var instance: Stats = self.duplicate()
	instance.health = max_health
	instance.block = 0
	instance.san = max_san
	return instance
