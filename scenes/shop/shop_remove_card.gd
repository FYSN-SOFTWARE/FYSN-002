class_name ShopRemoveCard
extends Control

@export var base_gold_cost: int = 75
var gold_cost: int

# 移除 @onready 修饰符，使用常规变量
var gold_label: Label
var button: Button

func _ready() -> void:
	# 确保节点存在后再获取引用
	gold_label = $GoldLabel
	button = $Button
	
	if gold_label and button:
		gold_cost = base_gold_cost
		update_gold_label()
		button.pressed.connect(_on_button_pressed)
	else:
		push_error("ShopRemoveCard: Missing required nodes!")

func update_gold_label() -> void:
	# 确保 gold_label 存在
	if gold_label:
		gold_label.text = str(gold_cost)

func update(run_stats: RunStats) -> void:
	# 确保 button 存在
	if button:
		button.disabled = run_stats.gold < gold_cost
		update_gold_label()

func _on_button_pressed() -> void:
	Events.emit_signal("shop_remove_requested", gold_cost)
