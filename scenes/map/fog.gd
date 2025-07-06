class_name FogManager
extends Node

# 信号：当房间探索状态改变时
signal room_explored(room: Room)

# 地图数据
var map_data: Array[Array]
# 所有房间的迷雾状态字典
var fog_states: Dictionary = {}

func initialize(map_data: Array[Array]) -> void:
	self.map_data = map_data
	reset_fog()

# 重置所有迷雾状态
func reset_fog() -> void:
	fog_states.clear()
	
	# 初始化所有房间为未探索状态
	for i in range(map_data.size()):
		for room in map_data[i]:
			fog_states[room] = false
	
	# 第一层房间总是可见
	if map_data.size() > 0:
		for room in map_data[0]:
			set_room_explored(room, true)

# 设置房间探索状态
func set_room_explored(room: Room, explored: bool) -> void:
	if fog_states.has(room) and fog_states[room] != explored:
		fog_states[room] = explored
		room_explored.emit(room)

# 获取房间探索状态
func is_room_explored(room: Room) -> bool:
	return fog_states.get(room, false)

# 探索当前房间及其相邻的下一层房间
func explore_room_and_neighbors(room: Room) -> void:
	set_room_explored(room, true)
	
	# 探索所有相邻的下一层房间
	for next_room in room.next_rooms:
		set_room_explored(next_room, true)

# 保存迷雾状态
func save_fog_states() -> Dictionary:
	var saved_states = {}
	for room in fog_states:
		saved_states[room_to_key(room)] = fog_states[room]
	return saved_states

# 加载迷雾状态
func load_fog_states(saved_states: Dictionary) -> void:
	for room in fog_states:
		var key = room_to_key(room)
		if saved_states.has(key):
			fog_states[room] = saved_states[key]

# 生成房间的唯一键
func room_to_key(room: Room) -> String:
	return "room_%d_%d" % [room.row, room.column]
