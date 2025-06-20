class_name ShopUpgradeCard
extends Control

@export var base_gold_cost: int = 100
var gold_cost: int

var gold_label: Label
var button: Button

func _ready() -> void:
	gold_label = $GoldLabel
	button = $Button
	
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
	if button:
		button.disabled = run_stats.gold < gold_cost
		update_gold_label()

func _on_button_pressed() -> void:
	Events.emit_signal("shop_upgrade_requested", gold_cost)
