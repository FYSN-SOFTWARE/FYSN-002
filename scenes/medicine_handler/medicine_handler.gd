# 药水处理器
# 管理玩家的药水槽位和使用逻辑
class_name MedicineHandler
extends Control


@export var player: Node2D  # 玩家节点引用
@export var status: Status

@onready var medicines_control: MedicinesControl = $MedicinesControl

var in_battle: bool = false  # 是否处于战斗

var medicine_slots: Array[Medicine] = []   # 药水槽位数组
var max_slots: int = 3  # 最大槽位数  TODO  槽位数可以改变的功能

func _ready() -> void:
	
	# 初始化药水槽位
	for i in range(max_slots):
		medicine_slots.append(null)
		
	# TODO 根据进阶等级调整槽位
	
	if not is_node_ready():
		await ready	
	medicines_control.medicine_handler = self
	
	Events.change_state.connect(_change_state)
	Events.medicine_discard_requested.connect(_medicine_discard)
	Events.medicine_use_requested.connect(_medicine_use)
	Events.medicine_get_requested.connect(_medicine_get)
		
# 添加药水到第一个空槽位
func add_medicine(medicine: Medicine) -> bool:
	for i in range(medicine_slots.size()):
		if medicine_slots[i] == null:
			medicine_slots[i] = medicine
			Events.medicines_updated.emit()  # 通知UI更新
			return true
	return false  # 所有槽位已满


func apply_medicine_effect(medicine: Medicine,double: bool,slot_index: int) -> void:
	# 计算实际效果值（考虑双倍效果）
	var effect_value = medicine.value * (2 if double else 1)
	
	# 根据药水类型执行效果
	medicine.use_medicine(medicines_control.medicine_uis[slot_index])

# TODO 检查药水是否不受神圣树皮影响

# 获取所有药水槽位状态
func get_medicines() -> Array[Medicine]:
	return medicine_slots

func _change_state(isinbattle:bool) -> void:
	if isinbattle:
		in_battle = true
	else:
		in_battle = false

func _medicine_discard(slot_index: int):
	if slot_index < 0 or slot_index >= medicine_slots.size():
		return
		
	# 清空槽位
	medicine_slots[slot_index] = null
	for child in medicines_control.get_children():
		child.icon.scale = Vector2(1,1)
		child.medicine_tooltip.hide_tooltip()
		child.medicine_use_select_ui.hide_options()
	Events.medicines_updated.emit()
	
func _medicine_use(slot_index: int):
	if slot_index < 0 or slot_index >= medicine_slots.size():
		return
		
	var medicine = medicine_slots[slot_index]
	if medicine == null:
		return
	
	for child in medicines_control.get_children():
		child.icon.scale = Vector2(1,1)
		child.medicine_tooltip.hide_tooltip()
		child.medicine_use_select_ui.hide_options()	
	
	print(in_battle)
	# 检查药水是否只能在战斗中使用
	if medicine.battle_only and not in_battle:
		print("此药水只能在战斗中使用")
		return
	
	# TODO: 检查神圣树皮是否生效
	var double_effect = false
	
	# 应用药水效果
	apply_medicine_effect(medicine,double_effect,slot_index)
	
	# 清空槽位
	medicine_slots[slot_index] = null
	Events.medicines_updated.emit()
	
	# TODO 触发遗物效果

func _medicine_get(medicine: Medicine):
	add_medicine(medicine)
