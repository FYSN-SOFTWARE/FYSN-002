extends CardState

func enter() -> void:
	#筛选卡片
	Battle.battle.card_choose_handler.check_card(card_ui)
	pass

func on_mouse_entered() -> void:
	
	#动画
	pass

func on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.is_action_pressed("left_mouse"):
			Battle.battle.card_choose_handler.add_card(card_ui)
		if event.is_action_pressed("right_mouse"):
			Battle.battle.card_choose_handler.card_remove(card_ui)
