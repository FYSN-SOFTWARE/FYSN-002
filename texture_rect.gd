extends TextureRect

@export var texture2 = Texture
@export var flip_duration = 0.5  # 翻转动画持续时间(秒)

var is_flipping = false
var original_texture = null

func _input(event):
	if event.is_action_pressed("right_mouse"):
		flip_card()  # 调用翻转卡牌的函数

func flip_card():

	if get_texture() == load("res://icon.svg"):
		set_texture(texture2)
	else:
		set_texture(load("res://icon.svg"))
