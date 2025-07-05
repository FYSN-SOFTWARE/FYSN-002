extends Control
class_name TutorialPopup

signal tutorial_completed

@onready var texture_rect: TextureRect = %TextureRect
@onready var label: Label = %Label
@onready var prev_button: Button = %PrevButton
@onready var next_button: Button = %NextButton
@onready var close_button: Button = %CloseButton

var pages: Array[Dictionary] = []
var current_page: int = 0
var is_closing: bool = false  # 添加关闭状态标志

func _ready() -> void:
	# 设置为处理模式为当暂停时也处理
	self.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# 确保可以接收输入
	self.mouse_filter = Control.MOUSE_FILTER_STOP  # 使用 STOP 而不是 PASS
	self.focus_mode = Control.FOCUS_ALL
	
	# 添加安全检查，确保按钮存在
	if prev_button:
		prev_button.pressed.connect(_on_prev_button_pressed)
		prev_button.mouse_filter = Control.MOUSE_FILTER_STOP
		prev_button.focus_mode = Control.FOCUS_ALL
	if next_button:
		next_button.pressed.connect(_on_next_button_pressed)
		next_button.mouse_filter = Control.MOUSE_FILTER_STOP
		next_button.focus_mode = Control.FOCUS_ALL
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
		close_button.mouse_filter = Control.MOUSE_FILTER_STOP
		close_button.focus_mode = Control.FOCUS_ALL
	
	# 确保弹窗可以接收输入
	self.grab_focus()
	
	update_buttons()


func set_pages(new_pages: Array[Dictionary]) -> void:
	pages = new_pages
	current_page = 0
	# 确保节点已准备就绪
	if is_inside_tree():
		show_page(0)
	else:
		# 如果节点未准备好，延迟执行
		call_deferred("show_page", 0)

func show_page(page_index: int) -> void:
	if page_index < 0 or page_index >= pages.size() or is_closing:
		return
	
	current_page = page_index
	var page = pages[page_index]
	
	# 清除旧内容
	if is_instance_valid(texture_rect):
		texture_rect.texture = null  # 清除旧纹理
	if is_instance_valid(label):
		label.text = ""  # 清除旧文本
	
	# 添加安全检查
	if is_instance_valid(texture_rect) and page.has("texture"):
		texture_rect.texture = page.get("texture")
	if is_instance_valid(label) and page.has("text"):
		label.text = page.get("text")
	
	# 强制更新UI
	label.queue_redraw()
	texture_rect.queue_redraw()
	update_buttons()

func update_buttons() -> void:
	if is_closing:
		return
	
	if prev_button:
		prev_button.visible = current_page > 0
		prev_button.disabled = false
	if next_button:
		next_button.visible = current_page < pages.size() - 1
		next_button.disabled = false
	if close_button:
		close_button.visible = current_page == pages.size() - 1
		close_button.disabled = false

func _on_prev_button_pressed() -> void:
	if is_closing:
		return
	print("Prev button pressed")
	show_page(current_page - 1)

func _on_next_button_pressed() -> void:
	if is_closing:
		return
	print("Next button pressed")
	show_page(current_page + 1)

func _on_close_button_pressed() -> void:
	if is_closing:
		return
	
	print("Close button pressed")
	is_closing = true  # 设置关闭标志
	
	# 在发出信号前禁用所有按钮
	if prev_button: 
		prev_button.disabled = true
	if next_button: 
		next_button.disabled = true
	if close_button: 
		close_button.disabled = true
	
	# 添加短暂延迟确保动画完成
	await get_tree().create_timer(0.1).timeout
	
	tutorial_completed.emit()
	queue_free()

# 添加析构函数，确保安全释放
func _exit_tree() -> void:
	# 断开所有信号连接
	if prev_button and prev_button.pressed.is_connected(_on_prev_button_pressed):
		prev_button.pressed.disconnect(_on_prev_button_pressed)
	if next_button and next_button.pressed.is_connected(_on_next_button_pressed):
		next_button.pressed.disconnect(_on_next_button_pressed)
	if close_button and close_button.pressed.is_connected(_on_close_button_pressed):
		close_button.pressed.disconnect(_on_close_button_pressed)
