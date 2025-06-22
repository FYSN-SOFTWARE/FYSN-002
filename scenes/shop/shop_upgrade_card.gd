class_name ShopUpgradeCard
extends Control

@export var base_gold_cost: int = 100
var gold_cost: int
var is_used: bool = false  # 新增使用状态标记

@onready var gold_label: Label = $GoldLabel
@onready var button: Button = $Button

func _ready() -> void:
	if gold_label and button:
		gold_cost = base_gold_cost
		update_gold_label()
		button.pressed.connect(_on_button_pressed)
	else:
		push_error("ShopUpgradeService: Missing required nodes!")

func update_gold_label() -> void:
	if gold_label:
		gold_label.text = str(gold_cost)

func update(run_stats: RunStats) -> void:
	# 如果已经使用，直接返回不再更新状态
	if is_used:
		return
	if button:
		button.disabled = run_stats.gold < gold_cost
		update_gold_label()

func _on_button_pressed() -> void:
	Events.emit_signal("shop_upgrade_requested", gold_cost)

# 新增方法：禁用按钮并设置文本
func disable_button() -> void:
	if button:
		button.disabled = true
		is_used = true  # 标记为已使用

# 新增方法：设置"已使用"文本
func set_used_text(text: String) -> void:
	if button:
		button.text = text
	if gold_label:
		gold_label.visible = false
