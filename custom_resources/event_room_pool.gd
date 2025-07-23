class_name EventRoomPool
extends Resource

@export var event_rooms: Array[PackedScene] = [
	preload("res://scenes/event_rooms/gamble_event.tscn"),
	preload("res://scenes/event_rooms/helpful_boi_event.tscn"),
	preload("res://scenes/event_rooms/bulletin_board_event.tscn")  # 添加公告栏事件
]

func get_random() -> PackedScene:
	return event_rooms.pick_random()
