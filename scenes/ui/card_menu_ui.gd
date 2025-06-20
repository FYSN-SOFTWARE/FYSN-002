class_name CardMenuUI
extends CenterContainer

signal tooltip_requested(card: Card)
signal pressed # 修改为无参数信号

const BASE_STYLEBOX := preload("res://scenes/card_ui/card_base_stylebox.tres")
const HOVER_STYLEBOX := preload("res://scenes/card_ui/card_hover_stylebox.tres")

@export var card: Card : set = set_card

@onready var visuals: CardVisuals = $Visuals

func _ready() -> void:
	# 确保接收鼠标事件
	mouse_filter = Control.MOUSE_FILTER_STOP
	visuals.mouse_filter = Control.MOUSE_FILTER_STOP
	# 连接鼠标事件
	visuals.mouse_entered.connect(visuals._on_mouse_entered)
	visuals.mouse_exited.connect(visuals._on_mouse_exited)
	# 确保连接 GUI 输入信号
	if not visuals.gui_input.is_connected(_on_visuals_gui_input):
		visuals.gui_input.connect(_on_visuals_gui_input)

func _on_visuals_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		# 同时触发工具提示和按下信号
		tooltip_requested.emit(card)
		pressed.emit() # 发出无参数信号


func _on_visuals_mouse_entered() -> void:
	visuals.panel.set("theme_override_styles/panel", HOVER_STYLEBOX)
	# 显示关键词提示
	visuals._on_mouse_entered()

func _on_visuals_mouse_exited() -> void:
	visuals.panel.set("theme_override_styles/panel", BASE_STYLEBOX)
	# 隐藏关键词提示
	visuals._on_mouse_exited()


func set_card(value: Card) -> void:
	if not is_node_ready():
		await ready

	card = value
	visuals.card = card
