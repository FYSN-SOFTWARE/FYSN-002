# 药水槽位UI
# 显示单个药水槽位
class_name MedicineUI
extends Control

const DEFAULT_MEDICINE = preload("res://medicines/default_medicine.tres")

@export var medicine: Medicine: set = set_medicine  # 当前槽位的药水

@onready var icon: TextureRect = $Icon  # 药水图标
@onready var medicine_tooltip: MedicineTooltip = $MedicineTooltip
@onready var medicine_use_select_ui: VBoxContainer = $MedicineUseSelectUI

var is_input_active = false
var slot_index: int = -1  # 槽位索引

func _ready() -> void:
	if not is_node_ready():
		await ready
	
	icon.mouse_entered.connect(_on_mouse_entered)
	icon.mouse_exited.connect(_on_mouse_exited)
	
func setup(index: int) -> void:
	slot_index = index
	medicine_use_select_ui.slot_index = slot_index

# 设置药水
func set_medicine(new_medicine: Medicine) -> void:
	if not is_node_ready():
		await ready
		
	if new_medicine:
		medicine = new_medicine
	else:
		medicine = DEFAULT_MEDICINE
	
	icon.texture = medicine.icon
			
func _on_mouse_entered():
	if not is_input_active:
		var tween := create_tween()
		tween.tween_property(icon,"scale",Vector2(1.2,1.2),0.2)
		
		
		var icon_top_screen: Vector2 = icon.get_global_transform_with_canvas().origin
		var icon_end_y = icon.get_global_rect().end.y
		medicine_tooltip.show_tooltip(medicine,icon_end_y)
	
	
func _on_mouse_exited():
	if not is_input_active:
		var tween := create_tween()
		tween.tween_property(icon,"scale",Vector2(1,1),0.2)
		
		medicine_tooltip.hide_tooltip()

# 点击事件处理
func _on_icon_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		for child in get_parent().get_children():
			child.icon.scale = Vector2(1,1)
			child.medicine_tooltip.hide_tooltip()
			child.medicine_use_select_ui.hide_options()
		
		if medicine == DEFAULT_MEDICINE:
			return
		
		is_input_active = true
		icon.scale = Vector2(1.2,1.2)
		medicine_tooltip.show_with_options(medicine,medicine_use_select_ui)
		medicine_use_select_ui.show_options()
		
	if event.is_action_pressed("right_mouse"):
		is_input_active = false
		icon.scale = Vector2(1,1)
		medicine_tooltip.hide_tooltip()
		medicine_use_select_ui.hide_options()
		
