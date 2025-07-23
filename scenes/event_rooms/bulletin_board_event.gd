extends EventRoom

@onready var poster_image: TextureRect = %PosterImage
@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var careful_button: EventRoomButton = $Background/HBoxContainer/VBoxContainer/ButtonContainer/CarefulButton
@onready var tear_button: EventRoomButton = $Background/HBoxContainer/VBoxContainer/ButtonContainer/TearButton
@onready var ignore_button: EventRoomButton = $Background/HBoxContainer/VBoxContainer/ButtonContainer/IgnoreButton

# 预加载遗物资源
const BLURRY_POSTER_RELIC = preload("res://relics/blurry_missing_poster.tres")

func _ready() -> void:
	# 检查遗物资源是否加载成功
	if not BLURRY_POSTER_RELIC:
		push_error("Failed to load blurry_missing_poster relic!")
	else:
		print("Blurry poster relic loaded: ", BLURRY_POSTER_RELIC.resource_path)

func setup() -> void:
	# 设置事件描述
	description_label.text = "破旧的公告栏上贴着一张褪色的失踪人口海报。\n照片上的人脸模糊不清，下方用潦草的字迹写着：\n'小心！下一个失踪的可能就是你...'"
	
	# 设置按钮回调 - 使用 Callable.bind() 确保正确传递上下文
	careful_button.event_button_callback = Callable(self, "_on_careful_pressed")
	tear_button.event_button_callback = Callable(self, "_on_tear_pressed")
	ignore_button.event_button_callback = Callable(self, "_on_ignore_pressed")
	print("Bulletin board event setup complete")

func _on_careful_pressed() -> void:
	# 小心撕下简报
	description_label.text = "你感到一丝寒意，但仍谨慎地将简报取下折好。"
	
	# 添加遗物"模糊的失踪简报"
	var relic_handler = get_tree().get_first_node_in_group("relic_handler")
	if relic_handler:
		relic_handler.add_relic(BLURRY_POSTER_RELIC)
	
	# 禁用所有按钮
	disable_all_buttons()
	
	# 延迟确保所有操作完成
	await get_tree().create_timer(2).timeout
	Events.event_room_exited.emit()
	print("Button pressed: ", name)

func _on_tear_pressed() -> void:
	# 粗暴撕碎简报
	description_label.text = "一股莫名的烦躁和恨意涌上心头，你狠狠地将简报撕成碎片！"
	
	# 获得50金币
	run_stats.gold += 50
	
	# 禁用所有按钮
	disable_all_buttons()
	
	# 延迟确保所有操作完成
	await get_tree().create_timer(2).timeout
	Events.event_room_exited.emit()
	print("Button pressed: ", name)

func _on_ignore_pressed() -> void:
	# 置之不理
	description_label.text = "你觉得这只是无聊的恐吓，转身离开。"
	
	# 禁用所有按钮
	disable_all_buttons()
	
	# 延迟确保所有操作完成
	await get_tree().create_timer(2).timeout
	Events.event_room_exited.emit()
	print("Button pressed: ", name)

func disable_all_buttons() -> void:
	careful_button.disabled = true
	tear_button.disabled = true
	ignore_button.disabled = true
