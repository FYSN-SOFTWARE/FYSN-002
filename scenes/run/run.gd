class_name Run
extends Node

const BATTLE_SCENE := preload("res://scenes/battle/battle.tscn")
const BATTLE_REWARD_SCENE := preload("res://scenes/battle_reward/battle_reward.tscn")
const CAMPFIRE_SCENE := preload("res://scenes/campfire/campfire.tscn")
const SHOP_SCENE := preload("res://scenes/shop/shop.tscn")
const TREASURE_SCENE = preload("res://scenes/treasure/treasure.tscn")
const WIN_SCREEN_SCENE := preload("res://scenes/win_screen/win_screen.tscn")
const MAIN_MENU_PATH := "res://scenes/ui/main_menu.tscn"
const FLIPPED_BATTLE_SCENE := preload("res://scenes/battle/flipped_battle.tscn")
const PROLOGUE_CG_SCENE := preload("res://scenes/map/prologue/cg_scene.tscn")
const PROLOGUE_MAP_GENERATOR = preload("res://scenes/map/prologue/prologue_map_generator.gd")

@export var run_startup: RunStartup


@onready var map: Map = $Map
@onready var current_view: Node = $CurrentView
@onready var health_ui: HealthUI = %HealthUI
@onready var gold_ui: GoldUI = %GoldUI
@onready var relic_handler: RelicHandler = %RelicHandler
@onready var relic_tooltip: RelicTooltip = %RelicTooltip
@onready var deck_button: CardPileOpener = %DeckButton
@onready var deck_view: CardPileView = %DeckView
@onready var pause_menu: PauseMenu = $PauseMenu

@onready var battle_button: Button = %BattleButton
@onready var campfire_button: Button = %CampfireButton
@onready var map_button: Button = %MapButton
@onready var rewards_button: Button = %RewardsButton
@onready var shop_button: Button = %ShopButton
@onready var treasure_button: Button = %TreasureButton
# 添加翻转按钮引用
@onready var flip_button: Button = %FlipButton

var stats: RunStats
var character: CharacterStats
var save_data: SaveGame
# 添加翻转状态变量
var is_flipped: bool = false
# 在类变量中添加（序章）
var is_prologue := false
var prologue_completed := false

func _ready() -> void:
	if not run_startup:
		return
	
	pause_menu.save_and_quit.connect(
		func(): 
			get_tree().change_scene_to_file(MAIN_MENU_PATH)
	)
	
	match run_startup.type:
		RunStartup.Type.NEW_RUN:
			character = run_startup.picked_character.create_instance()
			_start_run()
		RunStartup.Type.CONTINUED_RUN:
			_load_run()
			
	# 连接翻转按钮信号
	flip_button.pressed.connect(_on_flip_button_pressed)
	# 连接世界翻转事件
	Events.world_flipped.connect(_on_world_flipped)
	# 连接序章boss被击败事件
	Events.prologue_boss_defeated.connect(_on_prologue_boss_defeated)


func _start_run() -> void:
	stats = RunStats.new()

	# 如果是新游戏，检查是否开始序章
	if run_startup.type == RunStartup.Type.NEW_RUN:
		# 新游戏开始序章
		_start_prologue()
	else:
		# 继续游戏
		_load_run()

# 新增序章启动函数
func _start_prologue() -> void:
	is_prologue = true
	prologue_completed = false
	
	character = run_startup.picked_character.create_instance()
	stats.chapter = 0  # 0表示序章
	
	# 设置地图的 run_stats
	map.run_stats = stats
	
	_setup_event_connections()
	_setup_top_bar()
	
	# 确保资源池被正确初始化
	if not $Map/MapGenerator.battle_stats_pool:
		$Map/MapGenerator.battle_stats_pool = preload("res://battles/battle_stats_pool.tres")
		$Map/MapGenerator.battle_stats_pool.setup()
	
	if not $Map/MapGenerator.event_room_pool:
		$Map/MapGenerator.event_room_pool = preload("res://scenes/event_rooms/event_room_pool.tres")
	
	# 生成序章地图
	map.generate_new_map(0)
	map.unlock_floor(0)
	
	_save_prologue()

# 新增序章保存函数
func _save_prologue() -> void:
	save_data = SaveGame.new()
	save_data.rng_seed = RNG.instance.seed
	save_data.rng_state = RNG.instance.state
	save_data.run_stats = stats
	save_data.char_stats = character
	save_data.current_deck = character.deck
	save_data.current_health = character.health
	save_data.relics = relic_handler.get_all_relics()
	save_data.last_room = map.last_room
	save_data.map_data = map.map_data.duplicate()
	save_data.floors_climbed = map.floors_climbed
	save_data.was_on_map = true
	save_data.is_prologue = true
	save_data.save_data()

func _save_run(was_on_map: bool) -> void:
	save_data.rng_seed = RNG.instance.seed
	save_data.rng_state = RNG.instance.state
	save_data.run_stats = stats
	save_data.char_stats = character
	save_data.current_deck = character.deck
	save_data.current_health = character.health
	save_data.relics = relic_handler.get_all_relics()
	save_data.last_room = map.last_room
	save_data.map_data = map.map_data.duplicate()
	save_data.floors_climbed = map.floors_climbed
	save_data.was_on_map = was_on_map
	save_data.save_data()


# 新增翻转按钮处理函数
func _on_flip_button_pressed() -> void:
	is_flipped = !is_flipped
	flip_button.text = "里侧" if is_flipped else "表侧"
	
	# 保存翻转状态
	if save_data:
		save_data.is_flipped = is_flipped
		_save_run(true)

# 处理从战斗场景传来的翻转事件
func _on_world_flipped(flipped: bool) -> void:
	# 更新全局翻转状态
	is_flipped = flipped
	flip_button.text = "里侧" if is_flipped else "表侧"
	
	# 保存翻转状态
	if save_data:
		save_data.is_flipped = is_flipped
		_save_run(false)  # 不在地图上

func _change_view(scene: PackedScene) -> Node:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
	
	get_tree().paused = false
	
	# 确定要使用的场景
	var actual_scene: PackedScene = scene
	if scene == BATTLE_SCENE && is_flipped:
		actual_scene = FLIPPED_BATTLE_SCENE
	
	# 只创建一个场景实例
	var new_view := actual_scene.instantiate()
	current_view.add_child(new_view)
	map.hide_map()
	
	return new_view


func _on_event_room_exited() -> void:
	# 确保有返回地图的逻辑
	_show_map()
	print("Exiting event room")
	

func _show_map() -> void:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()

	map.show_map()
	map.unlock_next_rooms()
	
	_save_run(true)


func _setup_event_connections() -> void:
	Events.battle_won.connect(_on_battle_won)
	Events.battle_reward_exited.connect(_show_map)
	Events.campfire_exited.connect(_show_map)
	Events.map_exited.connect(_on_map_exited)
	Events.shop_exited.connect(_show_map)
	Events.treasure_room_exited.connect(_on_treasure_room_exited)
	Events.event_room_exited.connect(_on_event_room_exited)
	Events.world_flipped.connect(_on_world_flipped)
	
	battle_button.pressed.connect(_change_view.bind(BATTLE_SCENE))
	campfire_button.pressed.connect(_change_view.bind(CAMPFIRE_SCENE))
	map_button.pressed.connect(_show_map)
	rewards_button.pressed.connect(_change_view.bind(BATTLE_REWARD_SCENE))
	shop_button.pressed.connect(_change_view.bind(SHOP_SCENE))
	treasure_button.pressed.connect(_change_view.bind(TREASURE_SCENE))


func _setup_top_bar():
	character.stats_changed.connect(health_ui.update_stats.bind(character))
	health_ui.update_stats(character)
	gold_ui.run_stats = stats
	
	relic_handler.add_relic(character.starting_relic)
	Events.relic_tooltip_requested.connect(relic_tooltip.show_tooltip)
	
	deck_button.card_pile = character.deck
	deck_view.card_pile = character.deck
	deck_button.pressed.connect(deck_view.show_current_view.bind("Deck"))


func _show_regular_battle_rewards() -> void:
	var reward_scene := _change_view(BATTLE_REWARD_SCENE) as BattleReward
	reward_scene.run_stats = stats
	reward_scene.character_stats = character

	reward_scene.add_gold_reward(map.last_room.battle_stats.roll_gold_reward())
	reward_scene.add_card_reward()


func _on_battle_room_entered(room: Room) -> void:
	# 重置为表世界
	is_flipped = false
	if flip_button:
		flip_button.text = "表侧"
	
	# 保存状态
	if save_data:
		save_data.is_flipped = is_flipped
		_save_run(false)  # 不在地图上
	
	# 使用 _change_view 创建场景
	var battle_scene: Battle = _change_view(BATTLE_SCENE) as Battle
	
	battle_scene.char_stats = character
	battle_scene.battle_stats = room.battle_stats
	battle_scene.relics = relic_handler
	battle_scene.run_stats = stats  # 确保传递 run_stats
	battle_scene.start_battle()


func _on_treasure_room_entered() -> void:
	var treasure_scene := _change_view(TREASURE_SCENE) as Treasure
	treasure_scene.relic_handler = relic_handler
	treasure_scene.char_stats = character
	treasure_scene.generate_relic()


func _on_treasure_room_exited(relic: Relic) -> void:
	var reward_scene := _change_view(BATTLE_REWARD_SCENE) as BattleReward
	reward_scene.run_stats = stats
	reward_scene.character_stats = character
	reward_scene.relic_handler = relic_handler
	
	reward_scene.add_relic_reward(relic)


func _on_campfire_entered() -> void:
	var campfire := _change_view(CAMPFIRE_SCENE) as Campfire
	campfire.char_stats = character


func _on_shop_entered() -> void:
	var shop := _change_view(SHOP_SCENE) as Shop
	shop.char_stats = character
	shop.run_stats = stats
	shop.relic_handler = relic_handler
	Events.shop_entered.emit(shop)
	shop.populate_shop()


func _on_event_room_entered(room: Room) -> void:
	var event_room := _change_view(room.event_scene) as EventRoom
	event_room.character_stats = character
	event_room.run_stats = stats
	event_room.setup()
	print("Entering event room: ", room.event_scene.resource_path)

# 添加新的信号处理函数
func _on_prologue_boss_defeated() -> void:
	# 隐藏TopBar
	$TopBar.visible = false
	
	# 加载CG场景
	var cg_scene := PROLOGUE_CG_SCENE.instantiate()
	add_child(cg_scene)
	cg_scene.cg_completed.connect(_on_cg_completed)

# 新增CG完成回调
func _on_cg_completed() -> void:
	prologue_completed = true
	is_prologue = false
	stats.chapter = 1  # 进入第一章
	
	map.generate_new_map(1)
	map.unlock_floor(0)
	
	$TopBar.visible = true
	map.show_map()
	_save_run(true)  # 保存第一章状态


func _on_battle_won() -> void:
	_show_regular_battle_rewards()


func _load_run() -> void:
	save_data = SaveGame.load_data()
	assert(save_data, "Couldn't load last save")
	
	RNG.set_from_save_data(save_data.rng_seed, save_data.rng_state)
	stats = save_data.run_stats
	character = save_data.char_stats
	character.deck = save_data.current_deck
	character.health = save_data.current_health
	relic_handler.add_relics(save_data.relics)
	# 设置地图的 run_stats
	map.run_stats = stats
	
	_setup_top_bar()
	_setup_event_connections()
	
	# 检查是否是序章
	if save_data.is_prologue:
		# 加载序章地图
		map.load_map(save_data.map_data, save_data.floors_climbed, save_data.last_room)
		if save_data.last_room and not save_data.was_on_map:
			_on_map_exited(save_data.last_room)
	else:
		# 加载第一章地图
		map.load_map(save_data.map_data, save_data.floors_climbed, save_data.last_room)
		if save_data.last_room and not save_data.was_on_map:
			_on_map_exited(save_data.last_room)

func _on_map_exited(room: Room) -> void:
	_save_run(false)
	
	match room.type:
		Room.Type.MONSTER:
			_on_battle_room_entered(room)
		Room.Type.TREASURE:
			_on_treasure_room_entered()
		Room.Type.CAMPFIRE:
			_on_campfire_entered()
		Room.Type.SHOP:
			_on_shop_entered()
		Room.Type.BOSS:
			_on_battle_room_entered(room)
		Room.Type.EVENT:
			_on_event_room_entered(room)
