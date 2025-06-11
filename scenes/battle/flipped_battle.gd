extends Battle

func _ready() -> void:
	# 调用父类初始化
	super._ready()
	
	# 设置翻转背景
	is_flipped = true
	update_background()
	update_flip_button_text()
