class_name Campfire
extends Control

@export var char_stats: CharacterStats

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var rest_button: Button = %RestButton
@onready var meditate_button: Button = %MeditateButton  # 新增冥想按钮


func _ready() -> void:
	# 检查是否有冥想按钮
	if meditate_button:
		meditate_button.pressed.connect(_on_meditate_button_pressed)


func _on_rest_button_pressed() -> void:
	rest_button.disabled = true
	# 禁用冥想按钮（如果存在）
	if meditate_button:
		meditate_button.disabled = true
	
	char_stats.heal(ceili(char_stats.max_health * 0.3))
	animation_player.play("fade_out")


# 新增冥想功能
func _on_meditate_button_pressed() -> void:
	# 禁用两个按钮
	rest_button.disabled = true
	meditate_button.disabled = true
	
	# 回复30%的san值
	var heal_amount := ceili(char_stats.max_san * 0.3)
	char_stats.heal_san(heal_amount)
	
	animation_player.play("fade_out")


# This is called from the AnimationPlayer
# at the end of 'fade-out'.
func _on_fade_out_finished() -> void:
	Events.campfire_exited.emit()
