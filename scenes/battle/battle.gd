class_name Battle
extends Node2D

@export var battle_stats: BattleStats
@export var char_stats: CharacterStats
@export var music: AudioStream
@export var relics: RelicHandler

@onready var battle_ui: BattleUI = $BattleUI
@onready var player_handler: PlayerHandler = $PlayerHandler
@onready var enemy_handler: EnemyHandler = $EnemyHandler
@onready var player: Player = $Player
@onready var background: Sprite2D = $Background  # 确保场景中有背景节点
@onready var flip_button: Button = $FlipButton   # 添加按钮引用
# 背景资源
var normal_background = preload("res://art/background.png")
var flipped_background = preload("res://art/background_fanzhuan.png")

# 当前翻转状态
var is_flipped: bool = false

func _ready() -> void:
	enemy_handler.child_order_changed.connect(_on_enemies_child_order_changed)
	Events.enemy_turn_ended.connect(_on_enemy_turn_ended)
	
	Events.player_turn_ended.connect(player_handler.end_turn)
	Events.player_hand_discarded.connect(enemy_handler.start_turn)
	Events.player_died.connect(_on_player_died)
	# 连接翻转按钮信号
	if flip_button:  # 确保按钮存在
		flip_button.pressed.connect(_on_flip_button_pressed)
	
	# 初始化背景
	update_background()
	# 确保按钮文本正确
	update_flip_button_text()

func start_battle() -> void:
	get_tree().paused = false
	MusicPlayer.play(music, true)
	
	battle_ui.char_stats = char_stats
	player.stats = char_stats
	player_handler.relics = relics
	enemy_handler.setup_enemies(battle_stats)
	enemy_handler.reset_enemy_actions()
	
	relics.relics_activated.connect(_on_relics_activated)
	relics.activate_relics_by_type(Relic.Type.START_OF_COMBAT)
	# 确保背景和按钮更新
	update_background()
	update_flip_button_text()

# 添加方法初始化敌人状态
func initialize_enemies_flipped_state(flipped: bool) -> void:
	for enemy in enemy_handler.get_children():
		enemy.is_flipped = flipped
		enemy.update_appearance()
		enemy.update_behavior()
		enemy.update_stats_display()
		enemy.update_intent()

func _on_flip_button_pressed() -> void:
	# 切换翻转状态
	is_flipped = !is_flipped
	update_background()
	update_flip_button_text()
	# 通知全局翻转状态改变
	Events.world_flipped.emit(is_flipped)

func update_background() -> void:
	if is_flipped && flipped_background:
		background.texture = flipped_background
	else:
		background.texture = normal_background


func update_flip_button_text() -> void:
	if flip_button:
		flip_button.text = "返回表世界" if is_flipped else "进入里世界"

func _on_enemies_child_order_changed() -> void:
	if enemy_handler.get_child_count() == 0 and is_instance_valid(relics):
		relics.activate_relics_by_type(Relic.Type.END_OF_COMBAT)


func _on_enemy_turn_ended() -> void:
	player_handler.start_turn()
	enemy_handler.reset_enemy_actions()


func _on_player_died() -> void:
	Events.battle_over_screen_requested.emit("Game Over!", BattleOverPanel.Type.LOSE)
	SaveGame.delete_data()


func _on_relics_activated(type: Relic.Type) -> void:
	match type:
		Relic.Type.START_OF_COMBAT:
			player_handler.start_battle(char_stats)
			battle_ui.initialize_card_pile_ui()
		Relic.Type.END_OF_COMBAT:
			Events.battle_over_screen_requested.emit("Victorious!", BattleOverPanel.Type.WIN)
