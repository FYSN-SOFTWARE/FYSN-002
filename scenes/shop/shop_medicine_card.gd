class_name ShopMedicineCard
extends VBoxContainer

@export var medicine: Medicine : set = set_medicine

@onready var medicine_container: CenterContainer = $MedicineContainer
@onready var icon: TextureRect = $MedicineContainer/Icon
@onready var price_container: HBoxContainer = $PriceContainer
@onready var price_label: Label = $PriceContainer/PriceLabel
@onready var buy_button: Button = $PriceContainer/BuyButton

var gold_cost: int
var is_ready: bool = false

func _ready() -> void:
	is_ready = true
	# 确保所有节点已初始化
	_update_after_ready()
	if buy_button:
		buy_button.pressed.connect(_on_buy_button_pressed)

func set_medicine(new_medicine: Medicine) -> void:
	medicine = new_medicine
	if is_ready:
		_update_after_ready()

# 确保所有节点准备好后再更新
func _update_after_ready() -> void:
	if not medicine:
		return
		
	# 更新显示
	if icon:
		icon.texture = medicine.icon
	
	# 随机生成价格（50-150金）
	gold_cost = RNG.instance.randi_range(50, 150)
	
	if price_label:
		price_label.text = str(gold_cost)

func update(run_stats: RunStats) -> void:
	# 确保节点已初始化
	if not buy_button or not price_label:
		return
		
	if run_stats.gold >= gold_cost:
		price_label.remove_theme_color_override("font_color")
		buy_button.disabled = false
	else:
		price_label.add_theme_color_override("font_color", Color.RED)
		buy_button.disabled = true

func _on_buy_button_pressed() -> void:
	Events.shop_medicine_bought.emit(medicine, gold_cost)
	queue_free()  # 购买后移除卡片
