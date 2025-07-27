# 药水栏UI
# 管理所有药水槽位
class_name MedicinesControl
extends Control

@export var medicine_handler: MedicineHandler: set = set_medicine_handler

@onready var medicine_uis: Array[MedicineUI] = []

func _ready() -> void:
	# 初始化药水槽位
	for i in range(get_child_count()):
		var medicine_ui = get_child(i) as MedicineUI
		if medicine_ui:
			medicine_ui.setup(i)
			medicine_ui.medicine = null
			medicine_uis.append(medicine_ui)
			
	
	# 连接药水更新事件
	Events.medicines_updated.connect(_on_medicines_updated)
	
func set_medicine_handler(handler: MedicineHandler):
	if not is_node_ready():
		await ready
		
	medicine_handler = handler
	
# 更新所有槽位的药水显示
func _on_medicines_updated() -> void:
	var medicines = medicine_handler.get_medicines()
	for i in range(medicines.size()):
		medicine_uis[i].set_medicine(medicines[i])
