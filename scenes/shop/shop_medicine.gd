class_name ShopMedicine
extends VBoxContainer

# 使用新的商店药水UI
const SHOP_MEDICINE_UI = preload("res://scenes/shop/shop_medicine_ui.tscn")

@export var medicine: Medicine : set = set_medicine

@onready var medicine_ui_container: CenterContainer = %MedicineContainer
@onready var price: HBoxContainer = %Price
@onready var price_label: Label = %PriceLabel
@onready var buy_button: Button = %BuyButton
@onready var gold_cost: int = 0


func _ready() -> void:
	# 设置随机价格 (50-150金币)
	gold_cost = RNG.instance.randi_range(50, 150)
	update_price_label()
	
	# 确保按钮连接
	buy_button.pressed.connect(_on_buy_button_pressed)


func set_medicine(new_medicine: Medicine) -> void:
	if not is_node_ready():
		await ready

	medicine = new_medicine
	
	# 清除现有UI
	for child in medicine_ui_container.get_children():
		child.queue_free()
	
	# 创建新的商店药水UI
	var new_medicine_ui := SHOP_MEDICINE_UI.instantiate() as ShopMedicineUI
	medicine_ui_container.add_child(new_medicine_ui)
	new_medicine_ui.set_medicine(medicine)
	
	# 设置大小
	new_medicine_ui.custom_minimum_size = Vector2(80, 80)


func update(run_stats: RunStats) -> void:
	if not medicine_ui_container or not price or not buy_button:
		return

	update_price_label()
	
	if run_stats.gold >= gold_cost:
		price_label.remove_theme_color_override("font_color")
		buy_button.disabled = false
	else:
		price_label.add_theme_color_override("font_color", Color.RED)
		buy_button.disabled = true


func update_price_label() -> void:
	if price_label:
		price_label.text = str(gold_cost)


func _on_buy_button_pressed() -> void:
	if not medicine:
		push_error("No medicine set in ShopMedicine!")
		return
	
	Events.shop_medicine_bought.emit(medicine, gold_cost)
	
	# 禁用按钮防止重复购买
	buy_button.disabled = true
	buy_button.text = "已购买"
	
	# 隐藏价格标签
	price.visible = false
