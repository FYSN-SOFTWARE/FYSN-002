class_name ShopMedicineUI
extends Control

@export var medicine: Medicine

@onready var icon: TextureRect = $Icon
@onready var name_label: Label = $NameLabel
@onready var tooltip: RichTextLabel = $Tooltip

func _ready() -> void:
	# 确保控件可见
	visible = true
	show()
	
	# 设置最小尺寸
	custom_minimum_size = Vector2(80, 100)
	
	# 如果有药水，更新显示
	if medicine:
		set_medicine(medicine)

func set_medicine(new_medicine: Medicine) -> void:
	medicine = new_medicine
	
	if icon:
		icon.texture = medicine.icon if medicine else null
		icon.visible = medicine != null
	else:
		push_error("Icon node not found in ShopMedicineUI")
	
	if name_label:
		name_label.text = medicine.medicine_name if medicine else ""
		name_label.visible = medicine != null
	else:
		push_error("NameLabel node not found in ShopMedicineUI")
	
	if tooltip:
		tooltip.text = medicine.get_tooltip() if medicine else ""
		tooltip.visible = medicine != null
	else:
		push_error("Tooltip node not found in ShopMedicineUI")
	
	# 打印调试信息
	print("ShopMedicineUI set for: ", medicine.medicine_name if medicine else "null")
