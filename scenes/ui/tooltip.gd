class_name Tooltip
extends PanelContainer

@export var fade_seconds := 0.2

@onready var tooltip_icon: TextureRect = %TooltipIcon
@onready var tooltip_text_label: RichTextLabel = %TooltipText

var tween: Tween
var is_visible_now := false
var follow_target: Control = null  # 新增：跟随的目标控件


func _ready() -> void:
	Events.tooltip_hide_requested.connect(hide_tooltip)
	Events.tooltip_show_requested.connect(show_tooltip)
	# 确保工具提示不拦截鼠标事件
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_DISABLED
	# 确保启用BBCode解析
	tooltip_text_label.bbcode_enabled = true
	# 初始化为透明但可见，这样动画才能工作
	modulate = Color.TRANSPARENT
	show()

# 修改为始终显示在卡牌上
func show_tooltip(icon: Texture, text: String) -> void:
	if tween:
		tween.kill()
	
	tooltip_icon.texture = icon
	tooltip_text_label.text = text
	
	# 确保工具提示可见
	if modulate == Color.TRANSPARENT:
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "modulate", Color.WHITE, fade_seconds)

# 设置工具提示跟随的目标（卡牌）
func set_follow_target(target: Control) -> void:
	follow_target = target
	position = _calculate_position()

# 计算工具提示在卡牌上的位置
func _calculate_position() -> Vector2:
	if not follow_target:
		return Vector2.ZERO
	
	# 显示在卡牌顶部中央
	var target_rect = follow_target.get_global_rect()
	return Vector2(
		target_rect.position.x + (target_rect.size.x - size.x) / 2,
		target_rect.position.y - size.y - 10
	)

# 每帧更新位置
func _process(_delta: float) -> void:
	if follow_target and is_visible_in_tree():
		position = _calculate_position()

# 隐藏动画（仅当需要完全隐藏时使用）
func hide_tooltip() -> void:
	if tween:
		tween.kill()
	
	# 这里不再完全隐藏，而是保持透明状态
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_seconds)
