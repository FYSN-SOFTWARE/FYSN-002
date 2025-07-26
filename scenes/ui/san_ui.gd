class_name SanUI
extends HBoxContainer


#@export var show_max_hp: bool
#
#@onready var health_label: Label = %HealthLabel
#@onready var max_health_label: Label = %MaxHealthLabel
#
#
#func update_stats(stats: Stats) -> void:
	#health_label.text = str(stats.health)
	#max_health_label.text = "/%s" % str(stats.max_health)
	#max_health_label.visible = show_max_hp

@onready var san_label: Label = $SanLabel
@onready var max_san_label: Label = $MaxSanLabel

func update_stats(stats:Stats) ->void:
	# 只显示当前san值作为单一数字，类似血量显示
	san_label.text = str(stats.san)
	# 隐藏最大值标签
	max_san_label.visible = false
