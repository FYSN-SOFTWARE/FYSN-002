class_name Global
extends Node

static var is_world_flipped: bool = false

static func set_world_flipped(flipped: bool) -> void:
	is_world_flipped = flipped
	# 发出世界翻转事件
	Events.world_flipped.emit(flipped)
