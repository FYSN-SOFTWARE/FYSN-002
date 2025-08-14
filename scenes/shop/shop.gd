class_name Shop
extends Control

const SHOP_CARD = preload("res://scenes/shop/shop_card.tscn")
const SHOP_RELIC = preload("res://scenes/shop/shop_relic.tscn")
# 在常量区域添加预加载
const SHOP_REMOVE = preload("res://scenes/shop/shop_remove_card.tscn")
const SHOP_UPGRADE = preload("res://scenes/shop/shop_upgrade_card.tscn")
const SHOP_MEDICINE = preload("res://scenes/shop/shop_medicine_card.tscn")

# 添加删牌和强化功能的信号
signal shop_remove_requested(cost: int)
signal shop_upgrade_requested(cost: int)

@export var shop_relics: Array[Relic]
@export var char_stats: CharacterStats
@export var run_stats: RunStats
@export var relic_handler: RelicHandler

@onready var cards: HBoxContainer = %Cards
@onready var relics: HBoxContainer = %Relics
@onready var shop_keeper_animation: AnimationPlayer = %ShopkeeperAnimation
@onready var blink_timer: Timer = %BlinkTimer
@onready var card_tooltip_popup: CardTooltipPopup = %CardTooltipPopup
@onready var modifier_handler: ModifierHandler = $ModifierHandler
@onready var upgrades: HBoxContainer = %Services
# 商人对话配置
@onready var shopkeeper_dialogue: Label = %ShopkeeperDialogue
@onready var medicines_container: HBoxContainer = %MedicinesContainer

var welcome_phrases: Array[String] = [
	"旅人...你的灵魂在低语...这些碎片或许能平息它的饥渴...",
	"黑暗在聚集...而这里...是光的残影...",
	"每一次交易...都是命运的岔路...选择...然后承担..."
]
var purchase_phrases: Array[String] = [
	"力量...总是需要代价...",
	"这碎片...将成为你的枷锁...或羽翼...",
	"你的选择...正在编织新的命运之线..."
]
var service_phrases: Array[String] = [
	"改变形态...改变本质...但不变的...是终局...",
	"抹去过去...并不能逃避未来...",
	"强化的外表...脆弱的灵魂..."
]

# 新增升级服务使用标记
var remove_service_used: bool = false
var upgrade_service_used: bool = false  

func _ready() -> void:
	$AudioStreamPlayer.play()
	for shop_card: ShopCard in cards.get_children():
		shop_card.queue_free()
		
	for shop_relic: ShopRelic in relics.get_children():
		shop_relic.queue_free()
	
	Events.shop_card_bought.connect(_on_shop_card_bought)
	Events.shop_relic_bought.connect(_on_shop_relic_bought)
	# 添加事件连接
	Events.card_removed.connect(_on_card_removed)
	Events.card_upgraded.connect(_on_card_upgraded)
	# 添加新信号的连接
	Events.shop_remove_requested.connect(_on_shop_remove_requested)
	Events.shop_upgrade_requested.connect(_on_shop_upgrade_requested)
	Events.shop_medicine_bought.connect(_on_shop_medicine_bought)
	
	_blink_timer_setup()
	blink_timer.timeout.connect(_on_blink_timer_timeout)
	
	# 添加眨眼动画完成后的连接
	shop_keeper_animation.animation_finished.connect(_on_shopkeeper_animation_finished)


# 新增方法：显示随机对话
func _show_random_dialogue(phrase_list: Array[String]) -> void:
	if shopkeeper_dialogue:
		shopkeeper_dialogue.text = phrase_list[RNG.instance.randi_range(0, phrase_list.size() - 1)]
		shopkeeper_dialogue.visible = true
		
		# 设置定时器隐藏对话
		var timer := get_tree().create_timer(3.0)
		timer.timeout.connect(_on_dialogue_timer_timeout)

# 新增方法：处理对话定时器
func _on_dialogue_timer_timeout() -> void:
	if shopkeeper_dialogue:
		shopkeeper_dialogue.visible = false

# 新增方法：处理商人动画完成
func _on_shopkeeper_animation_finished(anim_name: String) -> void:
	if anim_name == "blink":
		# 小概率在眨眼后说一句话
		if RNG.instance.randf() < 0.4:  # 40%概率
			_show_random_dialogue(welcome_phrases)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and card_tooltip_popup.visible:
		card_tooltip_popup.hide_tooltip()


func populate_shop() -> void:
	_generate_shop_cards()
	_generate_shop_relics()
	_generate_shop_services()  # 新增服务选项
	_generate_shop_medicines()  # 新增药水生成
	

func _blink_timer_setup() -> void:
	blink_timer.wait_time = randf_range(1.0, 5.0)
	blink_timer.start()


func _generate_shop_cards() -> void:
	var shop_card_array: Array[Card] = []
	var available_cards: Array[Card] = char_stats.draftable_cards.duplicate_cards()
	RNG.array_shuffle(available_cards)
	shop_card_array = available_cards.slice(0, 4)
	
	for card: Card in shop_card_array:
		var new_shop_card := SHOP_CARD.instantiate() as ShopCard
		cards.add_child(new_shop_card)
		new_shop_card.card = card
		new_shop_card.current_card_ui.tooltip_requested.connect(card_tooltip_popup.show_tooltip)
		new_shop_card.gold_cost = _get_updated_shop_cost(new_shop_card.gold_cost)
		new_shop_card.update(run_stats)


func _generate_shop_relics() -> void:
	var shop_relics_array: Array[Relic] = []
	var available_relics := shop_relics.filter(
		func(relic: Relic):
			var can_appear := relic.can_appear_as_reward(char_stats)
			var already_had_it := relic_handler.has_relic(relic.id)
			return can_appear and not already_had_it
	)
	
	RNG.array_shuffle(available_relics)
	shop_relics_array = available_relics.slice(0, 4)
	
	for relic: Relic in shop_relics_array:
		var new_shop_relic := SHOP_RELIC.instantiate() as ShopRelic
		relics.add_child(new_shop_relic)
		new_shop_relic.relic = relic
		new_shop_relic.gold_cost = _get_updated_shop_cost(new_shop_relic.gold_cost)
		new_shop_relic.update(run_stats)

# 新增服务选项生成函数
func _generate_shop_services() -> void:
	# 添加空值检查
	if not is_instance_valid(upgrades):
		push_error("Upgrades container not found!")
		return
	
	# 清除现有服务（如果有）
	for child in upgrades.get_children():
		child.queue_free()
	
	# 添加删牌选项
	var shop_remove := SHOP_REMOVE.instantiate() as ShopRemoveCard
	upgrades.add_child(shop_remove)
	shop_remove.gold_cost = _get_updated_shop_cost(shop_remove.base_gold_cost)
	shop_remove.update(run_stats)

	# 如果删牌服务已使用，禁用按钮并显示"已使用"
	if remove_service_used:
		shop_remove.disable_button()
		shop_remove.set_used_text("已使用")

	# 添加强化选项
	var shop_upgrade := SHOP_UPGRADE.instantiate() as ShopUpgradeCard
	upgrades.add_child(shop_upgrade)
	shop_upgrade.gold_cost = _get_updated_shop_cost(shop_upgrade.base_gold_cost)
	shop_upgrade.update(run_stats)

	# 如果强化服务已使用，禁用按钮并显示"已使用"
	if upgrade_service_used:
		shop_upgrade.disable_button()
		shop_upgrade.set_used_text("已使用")


func _generate_shop_medicines() -> void:
	if not is_instance_valid(medicines_container):
		push_error("Medicines container not found!")
		return
	
	# 清除现有药水卡片
	for child in medicines_container.get_children():
		child.queue_free()
	
	# 获取所有可用药水
	var available_medicines = MedicineManager.get_all_medicines()
	RNG.array_shuffle(available_medicines)
	
	# 随机选择2-3个药水
	var num_medicines = RNG.instance.randi_range(2, 3)
	for i in range(min(num_medicines, available_medicines.size())):
		var medicine_card = SHOP_MEDICINE.instantiate() as ShopMedicineCard
		medicines_container.add_child(medicine_card)
		medicine_card.medicine = available_medicines[i]
		medicine_card.update(run_stats)


func _on_shop_medicine_bought(medicine: Medicine, cost: int) -> void:
	if run_stats.gold >= cost:
		run_stats.gold -= cost
		Events.medicine_get_requested.emit(medicine)
		_update_items()
		_show_random_dialogue(purchase_phrases)


# 新增服务事件处理
func _on_shop_remove_requested(cost: int) -> void:
	_show_card_selection_for_removal(cost)

func _on_shop_upgrade_requested(cost: int) -> void:
	_show_card_selection_for_upgrade(cost)

# 在商店中显示卡牌选择界面
func _show_card_selection_for_removal(cost: int) -> void:
	# 确保char_stats已被正确设置
	if not char_stats:
		push_error("CharacterStats is not set in Shop!")
		return
	
	# 创建CanvasLayer确保在最上层显示
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10  # 设置较高的层级
	get_tree().root.add_child(canvas_layer)
	
	# 创建卡牌选择视图
	var card_pile_view = preload("res://scenes/ui/card_pile_view.tscn").instantiate()
	canvas_layer.add_child(card_pile_view)  # 添加到CanvasLayer而不是根节点
	
	# 设置必要的属性
	card_pile_view.card_pile = char_stats.deck
	card_pile_view.char_stats = char_stats
	card_pile_view.run_stats = run_stats

	# 设置标志表示这是在商店中打开的
	card_pile_view.is_in_shop = true
	card_pile_view.canvas_layer = canvas_layer  # 存储canvas_layer引用

	# 确保设置 run_stats
	card_pile_view.run_stats = run_stats

	# 显示删牌选择界面
	card_pile_view.show_shop_action_view("选择要删除的卡牌", cost, "remove", true)

func _show_card_selection_for_upgrade(cost: int) -> void:
	# 确保char_stats已被正确设置
	if not char_stats:
		push_error("CharacterStats is not set in Shop!")
		return
	
	# 创建CanvasLayer确保在最上层显示
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10  # 设置较高的层级
	get_tree().root.add_child(canvas_layer)
	
	# 创建卡牌选择视图
	var card_pile_view = preload("res://scenes/ui/card_pile_view.tscn").instantiate()
	canvas_layer.add_child(card_pile_view)  # 添加到CanvasLayer而不是根节点
	
	# 设置必要的属性
	card_pile_view.card_pile = char_stats.deck
	card_pile_view.char_stats = char_stats
	card_pile_view.run_stats = run_stats
	
	# 设置标志表示这是在商店中打开的
	card_pile_view.is_in_shop = true
	card_pile_view.canvas_layer = canvas_layer  # 存储canvas_layer引用

	# 显示强化选择界面
	card_pile_view.show_shop_action_view("选择要升级的卡牌", cost, "upgrade", true)

func _on_card_removed(cost: int) -> void:
	# 标记删牌服务已使用
	remove_service_used = true
	# 更新商店物品显示
	_update_items()
	# 更新服务选项的费用
	_update_item_costs()
	# 禁用删牌按钮
	for child in upgrades.get_children():
		if child is ShopRemoveCard:
			child.disable_button()
			child.set_used_text("已使用")
	
	_show_random_dialogue(service_phrases)


func _on_card_upgraded(cost: int) -> void:
	# 标记强化服务已使用
	upgrade_service_used = true
	# 更新商店物品显示
	_update_items()
	# 更新服务选项的费用
	_update_item_costs()
	# 禁用强化按钮
	for child in upgrades.get_children():
		if child is ShopUpgradeCard:
			child.disable_button()
			child.set_used_text("已使用")
	
	_show_random_dialogue(service_phrases)


func _update_items() -> void:
	for shop_card: ShopCard in cards.get_children():
		shop_card.update(run_stats)

	for shop_relic: ShopRelic in relics.get_children():
		shop_relic.update(run_stats)

# 更新费用显示
func _update_item_costs() -> void:
	for shop_card: ShopCard in cards.get_children():
		shop_card.gold_cost = _get_updated_shop_cost(shop_card.gold_cost)
		shop_card.update(run_stats)

	for shop_relic: ShopRelic in relics.get_children():
		shop_relic.gold_cost = _get_updated_shop_cost(shop_relic.gold_cost)
		shop_relic.update(run_stats)
	# 更新服务选项的费用
	for child in upgrades.get_children():
		if child is ShopRemoveCard:
			child.gold_cost = _get_updated_shop_cost(child.base_gold_cost)
			child.update(run_stats)
		elif child is ShopUpgradeCard:
			child.gold_cost = _get_updated_shop_cost(child.base_gold_cost)
			child.update(run_stats)

func _get_updated_shop_cost(original_cost: int) -> int:
	return modifier_handler.get_modified_value(original_cost, Modifier.Type.SHOP_COST)


func _on_back_button_pressed() -> void:
	Events.shop_exited.emit()


func _on_shop_card_bought(card: Card, gold_cost: int) -> void:
	char_stats.deck.add_card(card)
	run_stats.gold -= gold_cost
	_update_items()

	_show_random_dialogue(purchase_phrases)


func _on_shop_relic_bought(relic: Relic, gold_cost: int) -> void:
	relic_handler.add_relic(relic)
	run_stats.gold -= gold_cost
	
	if relic is CouponsRelic:
		var coupons_relic := relic as CouponsRelic
		coupons_relic.add_shop_modifier(self)
		_update_item_costs()
	else:
		_update_items()
	
	_show_random_dialogue(purchase_phrases)


func _on_blink_timer_timeout() -> void:
	shop_keeper_animation.play("blink")
	_blink_timer_setup()
