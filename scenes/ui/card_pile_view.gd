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
# 添加删除按钮引用
@onready var delete_button: Button = %DeleteButton

var cost: int = 0
var action_type: String = ""
var is_in_shop: bool = false
var canvas_layer: CanvasLayer
# 添加选中的卡牌变量
var selected_card: Card = null

func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	# 连接删除按钮信号
	delete_button.pressed.connect(_on_delete_button_pressed)
	# 初始清除卡牌
	for card: Node in cards.get_children():
		card.queue_free()
	
	card_tooltip_popup.hide_tooltip()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if card_tooltip_popup.visible:
			card_tooltip_popup.hide_tooltip()
		else:
			hide()


func show_current_view(new_title: String,randomized: bool = false) -> void:
	# 重置状态
	cost = -1  # 设置为-1表示普通查看
	delete_button.hide()
	selected_card = null
	
	# 清除现有卡牌
	for card_ui in cards.get_children():
		card_ui.queue_free()

	card_tooltip_popup.hide_tooltip()
	title.text = new_title
	_update_view.call_deferred(randomized)

# 新增函数用于商店删牌
func show_shop_action_view(new_title: String, cost_value: int, randomized: bool = false) -> void:
	cost = cost_value
	delete_button.hide()
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

# 新增：处理卡牌选择
func _on_card_selected(card: Card) -> void:
	selected_card = card
	# 显示删除按钮并更新文本
	delete_button.text = "删除 (-%d金币)" % cost
	delete_button.disabled = (run_stats.gold < cost)
	delete_button.show()
	# 隐藏工具提示（如果有）
	card_tooltip_popup.hide_tooltip()

# 新增：处理删除按钮点击
func _on_delete_button_pressed() -> void:
	if selected_card and run_stats.gold >= cost:
		# 执行删除操作
		char_stats.deck.remove_card(selected_card)
		run_stats.gold -= cost
		Events.card_removed.emit(cost)
		
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
		delete_button.hide()
	else:
		# 没有选中的卡牌，直接关闭
		if canvas_layer:
			canvas_layer.queue_free()
		else:
			hide()
