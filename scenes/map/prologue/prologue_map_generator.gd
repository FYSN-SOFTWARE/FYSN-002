extends Node
class_name PrologueMapGenerator

const X_DIST := 200
const Y_DIST := 200

@export var battle_stats_pool: BattleStatsPool
@export var event_room_pool: EventRoomPool

var map_data: Array[Array]

# 序章固定房间序列
enum RoomSequence {
	MONSTER1,  # 第一个战斗房
	MONSTER2,  # 第二个战斗房
	EVENT,     # 事件房
	SHOP,      # 商店房
	BOSS       # BOSS房
}

func generate_map() -> Array[Array]:
	map_data = []
	
	# 创建5层序章地图（每层一个房间）
	for i in range(5):
		var room_row: Array[Room] = []
		var room := Room.new()
		room.position = Vector2(0, i * Y_DIST)
		room.row = i
		room.column = 0
		room.next_rooms = []
		
		# 设置房间类型
		match i:
			RoomSequence.MONSTER1, RoomSequence.MONSTER2:  # 前两个房间都是战斗房
				room.type = Room.Type.MONSTER
				# 添加空值检查
				if battle_stats_pool:
					room.battle_stats = battle_stats_pool.get_random_battle_for_tier(0)
				else:
					# 使用默认战斗配置
					room.battle_stats = preload("res://battles/tier_0_nurse.tres")
			
			RoomSequence.EVENT:  # 第三个房间是事件房
				room.type = Room.Type.EVENT
				# 添加空值检查
				if event_room_pool:
					room.event_scene = event_room_pool.get_random()
				else:
					# 使用默认事件场景
					room.event_scene = preload("res://scenes/event_rooms/bulletin_board_event.tscn")
	
			RoomSequence.SHOP:  # 第四个房间是商店房
				room.type = Room.Type.SHOP
	
			RoomSequence.BOSS:  # 第五个房间是BOSS房
				room.type = Room.Type.BOSS
				# 添加空值检查
				if battle_stats_pool:
					room.battle_stats = battle_stats_pool.get_random_battle_for_tier(1)
				else:
					# 使用默认BOSS配置
					room.battle_stats = preload("res://battles/tier_2_toxic_ghost.tres")
		
		room_row.append(room)
		map_data.append(room_row)
	
	# 连接房间（连接4次形成5个房间的链条）
	for i in range(4):
		map_data[i][0].next_rooms.append(map_data[i+1][0])
	
	return map_data
