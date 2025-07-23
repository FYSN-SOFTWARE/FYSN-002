extends CanvasLayer
class_name CGScene

signal cg_completed

@export var slides: Array[Texture2D]
@export var slide_texts: Array[String]
@export var slide_durations: Array[float] = [3.0, 3.0, 3.0, 3.0]

@onready var slide_timer: Timer = $SlideTimer
@onready var image: TextureRect = %Image
@onready var text_label: RichTextLabel = %TextLabel
@onready var skip_button: Button = %SkipButton

var current_slide := 0

func _ready() -> void:
	# 添加默认资源（如果数组为空）
	if slides.size() == 0:
		slides = [
			preload("res://art/cg/slide1.png"),
			preload("res://art/cg/slide2.png"),
			preload("res://art/cg/slide3.png")
		]
	
	if slide_texts.size() == 0:
		slide_texts = [
			"这是第一张幻灯片的文本",
			"这是第二张幻灯片的文本",
			"这是第三张幻灯片的文本"
		]
	
	# 连接信号
	skip_button.pressed.connect(skip)
	slide_timer.timeout.connect(next_slide)
	
	# 显示第一张幻灯片
	show_slide(0)

func show_slide(index: int) -> void:
	# 检查是否所有幻灯片都已显示
	if index >= slides.size() || index >= slide_texts.size():
		finish_cg()
		return
	
	# 设置当前幻灯片内容
	image.texture = slides[index]
	text_label.text = slide_texts[index]
	
	# 启动计时器（确保索引在有效范围内）
	var duration_index = min(index, slide_durations.size() - 1)
	slide_timer.start(slide_durations[duration_index])
	
	current_slide = index

func next_slide() -> void:
	show_slide(current_slide + 1)

func skip() -> void:
	finish_cg()

func finish_cg() -> void:
	emit_signal("cg_completed")
	queue_free()
