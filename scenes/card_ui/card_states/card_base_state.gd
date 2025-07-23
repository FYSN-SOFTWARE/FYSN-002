extends CardState

var last_mouse_position := Vector2.ZERO


func enter() -> void:
	if not card_ui.is_node_ready():
		await card_ui.ready

	if card_ui.tween and card_ui.tween.is_running():
		card_ui.tween.kill()

	card_ui.card_visuals.panel.set("theme_override_styles/panel", card_ui.BASE_STYLEBOX)
	card_ui.reparent_requested.emit(card_ui)
	card_ui.pivot_offset = Vector2.ZERO
	Events.tooltip_hide_requested.emit()


func on_gui_input(event: InputEvent) -> void:
	if not card_ui.playable or card_ui.disabled:
		return

	# 实时检测鼠标是否在卡牌上（包括tooltip区域）
	var is_mouse_over := card_ui.get_global_rect().has_point(card_ui.get_global_mouse_position())
	
	if is_mouse_over and event.is_action_pressed("left_mouse"):
		card_ui.pivot_offset = card_ui.get_global_mouse_position() - card_ui.global_position
		transition_requested.emit(self, CardState.State.CLICKED)
	
	# 更新鼠标位置用于悬停检测
	if event is InputEventMouseMotion:
		last_mouse_position = card_ui.get_global_mouse_position()


func on_mouse_entered() -> void:
	# 使用实时检测替代信号
	pass


func on_mouse_exited() -> void:
	# 使用实时检测替代信号
	pass


# 在process中处理悬停效果，确保覆盖整个卡牌区域
func _process(_delta: float) -> void:
	if not card_ui.playable or card_ui.disabled:
		return

	var is_mouse_over := card_ui.get_global_rect().has_point(last_mouse_position)
	
	if is_mouse_over:
		card_ui.card_visuals.panel.set("theme_override_styles/panel", card_ui.HOVER_STYLEBOX)
		card_ui.request_tooltip()
	else:
		card_ui.card_visuals.panel.set("theme_override_styles/panel", card_ui.BASE_STYLEBOX)
		Events.tooltip_hide_requested.emit()
