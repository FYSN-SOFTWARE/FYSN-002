extends Relic

# 这个遗物在特定事件中提供额外选项
func initialize_relic(owner: RelicUI) -> void:
	# 连接到事件系统
	Events.special_event_triggered.connect(_on_special_event_triggered.bind(owner))

func deactivate_relic(owner: RelicUI) -> void:
	Events.special_event_triggered.disconnect(_on_special_event_triggered)

func _on_special_event_triggered(event_id: String, owner: RelicUI) -> void:
	if event_id == "missing_person_followup":
		# 在后续事件中显示额外选项
		owner.flash()
