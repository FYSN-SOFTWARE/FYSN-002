class_name CardPileView
extends Control

const CARD_MENU_UI_SCENE := preload("res://scenes/ui/card_menu_ui.tscn")

@export var card_pile: CardPile
# 添加这些导出属性
@export var char_stats: CharacterStats
@export var run_stats: RunStats

@onready var title: Label = %Title
@onready var cards: GridContainer = %Cards
@onready var card_tooltip_popup: CardTooltipPopup = %CardTooltipPopup
@onready var back_button: Button = %BackButton
# 重命名为更通用的名称
@onready var action_button: Button = %DeleteButton

var cost: int = 0
var action_type: String = ""  # 添加操作类型变量
var is_in_shop: bool = false
var canvas_layer: CanvasLayer
# 添加选中的卡牌变量
var selected_card: Card = null

func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	# 连接动作按钮信号
	action_button.pressed.connect(_on_action_button_pressed)
	# 初始清除卡牌
	for card: Node in cards.get_children():
		card.queue_free()
	
	card_tooltip_popup.hide_tooltip()
	action_button.hide()  # 初始隐藏按钮


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if card_tooltip_popup.visible:
			card_tooltip_popup.hide_tooltip()
		else:
			hide()

# 用于普通牌库查看
func show_current_view(new_title: String, randomized: bool = false) -> void:
	# 重置状态
	cost = -1  # 设置为-1表示普通查看
	action_button.hide()
	selected_card = null
	action_type = ""
	
	# 清除现有卡牌
	for card_ui in cards.get_children():
		card_ui.queue_free()

	card_tooltip_popup.hide_tooltip()
	title.text = new_title
	_update_view.call_deferred(randomized)

# 新增函数用于商店删牌
func show_shop_action_view(new_title: String, cost_value: int, action: String, randomized: bool = false) -> void:
	cost = cost_value
	action_type = action  # 保存操作类型
	action_button.hide()
	selected_card = null
	
	# 清除现有卡牌
	for card_ui in cards.get_children():
		card_ui.queue_free()

	card_tooltip_popup.hide_tooltip()
	title.text = new_title
	_update_view.call_deferred(randomized)

func _update_view(randomized: bool) -> void:
	if not card_pile:
		return
	
	var all_cards := card_pile.cards.duplicate()
	if randomized:
		all_cards.shuffle()
	
	for card: Card in all_cards:
		var new_card := CARD_MENU_UI_SCENE.instantiate()
		if not new_card:
			push_error("Failed to instantiate CardMenuUI")
			continue
			
		cards.add_child(new_card)
		new_card.card = card
		new_card.tooltip_requested.connect(card_tooltip_popup.show_tooltip)
		
		# 关键修复：连接卡牌点击信号
		new_card.pressed.connect(_on_card_selected.bind(card))
		
	show()

# 处理卡牌选择
func _on_card_selected(card: Card) -> void:
	selected_card = card
	
	# 只在商店操作中显示按钮
	if action_type == "remove" || action_type == "upgrade":
		if action_type == "remove":
			action_button.text = "删除 (-%d金币)" % cost
		elif action_type == "upgrade":
			action_button.text = "强化 (-%d金币)" % cost
		
		# 只有在商店场景中才检查金币
		if is_in_shop && run_stats != null:
			action_button.disabled = (run_stats.gold < cost)
		else:
			# 非商店场景不检查金币，直接启用按钮
			action_button.disabled = false
		
		action_button.show()
	
	card_tooltip_popup.hide_tooltip()

# 处理动作按钮点击
func _on_action_button_pressed() -> void:
	if not selected_card:
		push_error("No card selected in CardPileView!")
		return
	
	var can_perform_action = true
	
	# 只有在商店场景中才检查金币
	if is_in_shop && run_stats != null:
		if run_stats.gold < cost:
			push_error("Not enough gold for action!")
			can_perform_action = false
		else:
			# 有足够金币
			can_perform_action = true
	else:
		# 非商店场景直接允许操作
		can_perform_action = true
	
	if can_perform_action:
		# 根据操作类型执行不同操作
		if action_type == "remove":
			if char_stats != null:
				char_stats.deck.remove_card(selected_card)
			if run_stats != null:
				run_stats.gold -= cost
			Events.card_removed.emit(cost)
		elif action_type == "upgrade":
			selected_card.upgrade()
			if run_stats != null:
				run_stats.gold -= cost
			Events.card_upgraded.emit(cost)
		
		# 关闭当前视图
		if canvas_layer:
			canvas_layer.queue_free()
		else:
				hide()

# 修改返回按钮处理
func _on_back_button_pressed() -> void:
	# 如果有选中的卡牌，取消选择
	if selected_card:
		selected_card = null
		action_button.hide()
	else:
		# 没有选中的卡牌，直接关闭
		if canvas_layer:
			canvas_layer.queue_free()
		else:
			hide()
