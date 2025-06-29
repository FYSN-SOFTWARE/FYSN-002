extends Control
class_name TutorialPopup

signal tutorial_completed

@onready var texture_rect: TextureRect = $VBoxContainer/TextureRect
@onready var label: RichTextLabel = $VBoxContainer/Label
@onready var prev_button: Button = $VBoxContainer/HBoxContainer/PrevButton
@onready var next_button: Button = $VBoxContainer/HBoxContainer/NextButton
@onready var close_button: Button = $VBoxContainer/HBoxContainer/CloseButton

var pages: Array[Dictionary] = []
var current_page: int = 0
var is_closing: bool = false  # 添加关闭状态标志

func _ready() -> void:
	# 添加安全检查，确保按钮存在
	if prev_button:
		prev_button.pressed.connect(_on_prev_button_pressed)
	if next_button:
		next_button.pressed.connect(_on_next_button_pressed)
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
	
	update_buttons()

func set_pages(new_pages: Array[Dictionary]) -> void:
	pages = new_pages
	current_page = 0
	show_page(0)

func show_page(page_index: int) -> void:
	if page_index < 0 or page_index >= pages.size() or is_closing:
		return
	
	current_page = page_index
	var page = pages[page_index]
	
	if texture_rect:
		texture_rect.texture = page.get("texture")
	if label:
		label.text = page.get("text")
	
	update_buttons()

func update_buttons() -> void:
	if is_closing:
		return
	
	if prev_button:
		prev_button.visible = current_page > 0
	if next_button:
		next_button.visible = current_page < pages.size() - 1
	if close_button:
		close_button.visible = current_page == pages.size() - 1

func _on_prev_button_pressed() -> void:
	if is_closing:
		return
	show_page(current_page - 1)

func _on_next_button_pressed() -> void:
	if is_closing:
		return
	show_page(current_page + 1)

func _on_close_button_pressed() -> void:
	if is_closing:
		return
	
	is_closing = true  # 设置关闭标志
	
	# 在发出信号前禁用所有按钮
	if prev_button: 
		prev_button.disabled = true
	if next_button: 
		next_button.disabled = true
	if close_button: 
		close_button.disabled = true
	
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
