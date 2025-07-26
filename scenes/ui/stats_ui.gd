class_name StatsUI
extends HBoxContainer

@onready var block: HBoxContainer = $Block
@onready var block_label: Label = %BlockLabel
@onready var health: HealthUI = $Health
@onready var san_ui: SanUI = $SanUI

# 添加世界翻转状态变量
var is_world_flipped: bool = false

func update_stats(stats: Stats) -> void:
	block_label.text = str(stats.block)
	health.update_stats(stats)
	san_ui.update_stats(stats)
	
	# 根据世界翻转状态显示不同的状态
	if is_world_flipped:  # 里世界
		block.visible = false
		health.visible = false
		san_ui.visible = stats.max_san > 0
	else:  # 表世界
		block.visible = stats.block > 0
		health.visible = stats.health > 0
		san_ui.visible = false

# 添加方法更新世界状态
func set_world_state(flipped: bool) -> void:
	is_world_flipped = flipped
	block.visible = stats.block > 0
	health.visible = stats.health > 0
