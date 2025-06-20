class_name Shop
extends Control

const SHOP_CARD = preload("res://scenes/shop/shop_card.tscn")
const SHOP_RELIC = preload("res://scenes/shop/shop_relic.tscn")
# 在常量区域添加预加载
const SHOP_REMOVE = preload("res://scenes/shop/shop_remove_card.tscn")
const SHOP_UPGRADE = preload("res://scenes/shop/shop_upgrade_card.tscn")

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


func _ready() -> void:
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

	_blink_timer_setup()
	blink_timer.timeout.connect(_on_blink_timer_timeout)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and card_tooltip_popup.visible:
		card_tooltip_popup.hide_tooltip()


func populate_shop() -> void:
	_generate_shop_cards()
	_generate_shop_relics()
	_generate_shop_services()  # 新增服务选项

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
	
	# 添加强化选项
	var shop_upgrade := SHOP_UPGRADE.instantiate() as ShopUpgradeCard
	upgrades.add_child(shop_upgrade)
	shop_upgrade.gold_cost = _get_updated_shop_cost(shop_upgrade.base_gold_cost)
	shop_upgrade.update(run_stats)


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

	# 显示删牌选择界面
	card_pile_view.show_shop_action_view("选择要删除的卡牌", cost,true)

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
	card_pile_view.show_current_view("upgrade", cost,true)

func _on_card_removed(cost: int) -> void:
	run_stats.gold -= cost
	# 更新商店物品显示
	_update_items()
	# 更新服务选项的费用
	_update_item_costs()

func _on_card_upgraded(cost: int) -> void:
	run_stats.gold -= cost
	# 更新商店物品显示
	_update_items()
	# 更新服务选项的费用
	_update_item_costs()

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


func _on_shop_relic_bought(relic: Relic, gold_cost: int) -> void:
	relic_handler.add_relic(relic)
	run_stats.gold -= gold_cost

	if relic is CouponsRelic:
		var coupons_relic := relic as CouponsRelic
		coupons_relic.add_shop_modifier(self)
		_update_item_costs()
	else:
		_update_items()


func _on_blink_timer_timeout() -> void:
	shop_keeper_animation.play("blink")
	_blink_timer_setup()
