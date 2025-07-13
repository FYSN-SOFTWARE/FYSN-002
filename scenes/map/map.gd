class_name Map
extends Node2D

const SCROLL_SPEED := 50
const MAP_ROOM = preload("res://scenes/map/map_room.tscn")
const MAP_LINE = preload("res://scenes/map/map_line.tscn")
const PROLOGUE_MAP_GENERATOR = preload("res://scenes/map/prologue/prologue_map_generator.gd")

@onready var map_generator: MapGenerator = $MapGenerator
@onready var lines: Node2D = %Lines
@onready var rooms: Node2D = %Rooms
@onready var visuals: Node2D = $Visuals
@onready var camera_2d: Camera2D = $Camera2D

var map_data: Array[Array]
var floors_climbed: int
var last_room: Room
var camera_edge_y: float
var current_chapter: int = 1  # 1表示正式地图，0表示序章
var run_stats: RunStats
var fog_manager: FogManager

func _ready() -> void:
	camera_edge_y = MapGenerator.Y_DIST * (MapGenerator.FLOORS - 1)
	# 初始化迷雾管理器
	fog_manager = FogManager.new()
	# 确保 run_stats 被正确设置
	if run_stats == null:
		push_warning("RunStats is null in Map!")

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event.is_action_pressed("scroll_up"):
		camera_2d.position.y -= SCROLL_SPEED
	elif event.is_action_pressed("scroll_down"):
		camera_2d.position.y += SCROLL_SPEED

	camera_2d.position.y = clamp(camera_2d.position.y, 0, camera_edge_y)


func generate_new_map(chapter: int = 1) -> void:
	floors_climbed = 0
	current_chapter = chapter  # 保存当前章节信息

	if chapter == 0:  # 0表示序章
		map_data = PROLOGUE_MAP_GENERATOR.new().generate_map()
	else:
		map_data = map_generator.generate_map()
	
	create_map()

	const Y_DIST := 200
	# 调整地图位置（序章只有一行，需要居中显示）
	if map_data.size() > 0 and map_data[0].size() == 1:
		# 序章地图只有单列，居中显示
		var map_height_pixels = Y_DIST * (map_data.size() - 1)
		visuals.position.y = (get_viewport_rect().size.y - map_height_pixels) / 2


func load_map(map: Array[Array], floors_completed: int, last_room_climbed: Room) -> void:
	floors_climbed = floors_completed
	map_data = map
	last_room = last_room_climbed
	create_map()
	
	if floors_climbed > 0:
		unlock_next_rooms()
	else:
		unlock_floor()


func create_map() -> void:
	# 清空现有房间和线条
	for child in rooms.get_children():
		child.queue_free()
	
	# 初始化迷雾管理器
	fog_manager.initialize(map_data)
	fog_manager.room_explored.connect(_on_room_explored)
	
	# 生成所有房间
	for current_floor in map_data:
		for room in current_floor:
			_spawn_room(room)
	
	# 生成所有房间
	for current_floor in map_data:
		for room in current_floor:
			_spawn_room(room)
	
	# 调整地图位置
	if current_chapter == 0:  # 序章地图
		# 序章地图居中显示
		const Y_DIST := 200
		var map_height_pixels = Y_DIST * (map_data.size() - 1)
		visuals.position.y = (get_viewport_rect().size.y - map_height_pixels) / 2
		visuals.position.x = get_viewport_rect().size.x / 2
	else:  # 正式地图
		visuals.position.x = (get_viewport_rect().size.x - MapGenerator.X_DIST * (MapGenerator.MAP_WIDTH - 1)) / 2
		visuals.position.y = 0 


func unlock_floor(which_floor: int = floors_climbed) -> void:
	for map_room: MapRoom in rooms.get_children():
		if map_room.room.row == which_floor:
			map_room.available = true


func show_map() -> void:
	show()
	camera_2d.enabled = true


func hide_map() -> void:
	hide()
	camera_2d.enabled = false


func _spawn_room(room: Room) -> void:
	var new_map_room := MAP_ROOM.instantiate() as MapRoom
	rooms.add_child(new_map_room)
	new_map_room.room = room
	new_map_room.clicked.connect(_on_map_room_clicked)
	new_map_room.selected.connect(_on_map_room_selected)
	_connect_lines(room)
	
	if room.selected and room.row < floors_climbed:
		new_map_room.show_selected()
	# 设置初始迷雾状态
	new_map_room.set_explored(fog_manager.is_room_explored(room))


# 房间探索状态变化时的处理
func _on_room_explored(room: Room) -> void:
	for map_room in rooms.get_children():
		if map_room.room == room:
			map_room.set_explored(true)

# 解锁下一层房间
func unlock_next_rooms() -> void:
	for map_room: MapRoom in rooms.get_children():
		if last_room and last_room.next_rooms.has(map_room.room):
			fog_manager.set_room_explored(map_room.room, true)
			map_room.available = true


func _connect_lines(room: Room) -> void:
	if room.next_rooms.is_empty():
		return
		
	for next: Room in room.next_rooms:
		var new_map_line := MAP_LINE.instantiate() as Line2D
		new_map_line.add_point(room.position)
		new_map_line.add_point(next.position)
		lines.add_child(new_map_line)


func _on_map_room_clicked(room: Room) -> void:
	for map_room: MapRoom in rooms.get_children():
		if map_room.room.row == room.row:
			map_room.available = false


func _on_map_room_selected(room: Room) -> void:
	last_room = room
	floors_climbed += 1
	# 探索当前房间及其相邻房间
	fog_manager.explore_room_and_neighbors(room)
	# 更新当前房间索引（用于序章教学）
	if run_stats:
		run_stats.current_room_index = room.row
	Events.map_exited.emit(room)

# 保存地图时保存迷雾状态
func save_map_state() -> Dictionary:
	return {
		"map_data": map_data,
		"fog_states": fog_manager.save_fog_states()
	}

# 加载地图时加载迷雾状态
func load_map_state(saved_data: Dictionary) -> void:
	map_data = saved_data["map_data"]
	fog_manager.initialize(map_data)
	fog_manager.load_fog_states(saved_data["fog_states"])
