class_name Battle
extends Node2D

@export var battle_stats: BattleStats
@export var char_stats: CharacterStats
@export var music: AudioStream
@export var relics: RelicHandler
@export var run_stats: RunStats

@onready var battle_ui: BattleUI = $BattleUI
@onready var player_handler: PlayerHandler = $PlayerHandler
@onready var enemy_handler: EnemyHandler = $EnemyHandler
@onready var player: Player = $Player
@onready var background: Sprite2D = $Background  # 确保场景中有背景节点
@onready var flip_button: Button = $FlipButton   # 添加按钮引用
@onready var mana: ManaUI = %Mana

static var battle: Battle

# 背景资源
var normal_background = preload("res://art/场景/BigBirdArrived.png")
var flipped_background = preload("res://art/场景/BigBirdDead.png")
# 当前翻转状态
var is_flipped: bool = false
# 添加教程系统
var tutorial_system: TutorialBattle

func _init() -> void:
	if (not battle):
		battle = self
	else: if(battle == self):
		return
	else:
		queue_free()

func _ready() -> void:
	$biao.play()
	enemy_handler.child_order_changed.connect(_on_enemies_child_order_changed)
	Events.enemy_turn_ended.connect(_on_enemy_turn_ended)
	
	Events.player_turn_ended.connect(player_handler.end_turn)
	Events.player_hand_discarded.connect(enemy_handler.start_turn)
	Events.player_died.connect(_on_player_died)
	Events.player_san_damage_taken.connect(_on_player_san_damage_taken)
	
	# 连接翻转按钮信号
	if flip_button:  # 确保按钮存在
		flip_button.pressed.connect(_on_flip_button_pressed)
	# 初始化背景
	update_background()
	# 确保按钮文本正确
	update_flip_button_text()
	# 连接战斗开始信号
	Events.battle_started.connect(_on_battle_started)

func start_battle() -> void:
	get_tree().paused = false
	Global.set_world_flipped(is_flipped)
	battle_ui.char_stats = char_stats
	player.stats = char_stats
	player_handler.relics = relics
	enemy_handler.setup_enemies(battle_stats)
	enemy_handler.reset_enemy_actions()
	
	relics.relics_activated.connect(_on_relics_activated)
	
	# 确保背景和按钮更新
	update_background()
	update_flip_button_text()
	
	# 激活遗物并开始战斗
	relics.activate_relics_by_type(Relic.Type.START_OF_COMBAT)
	
	# 初始化教程系统
	if run_stats != null:
		tutorial_system = TutorialBattle.new(self, run_stats)
		# 检查并显示教程
		tutorial_system.check_and_show_tutorial()
	else:
		# 如果没有教程，直接开始战斗
		player_handler.start_battle(char_stats)
		battle_ui.initialize_card_pile_ui()


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
<<<<<<< Updated upstream
=======
	$biao.stop()
	$li.play()
	if is_flipped:
		return
	if not can_enter_flipped_world():
		return
	#if not is_flipped and not can_enter_flipped_world():
		#return
>>>>>>> Stashed changes
	is_flipped = !is_flipped
	
	Global.set_world_flipped(is_flipped) 
	update_background()
	update_flip_button_text()
<<<<<<< Updated upstream
	# 通知全局翻转状态改变
	Events.world_flipped.emit(is_flipped)

=======
	
	# 更新玩家状态UI的世界状态
	if player and player.stats_ui:
		player.stats_ui.set_world_state(is_flipped)
		player.update_stats()  # 刷新UI显示
	
	
	# 获取当前手牌中的卡牌
	var hand_cards: Array[Card] = []
	if battle_ui and battle_ui.hand:
		for card_ui in battle_ui.hand.get_children():
			if card_ui is CardUI:
				hand_cards.append(card_ui.card)
	
	# 发送带手牌信息的信号
	Events.world_flipped_with_hand.emit(is_flipped, hand_cards)
	Events.world_flipped.emit(is_flipped)


func _on_world_flipped(flipped: bool) -> void:
	is_flipped = flipped
	
	# 更新UI组件
	update_background()
	update_flip_button_text()
	
	# 更新玩家状态UI
	if player and player.stats_ui:
		player.stats_ui.set_world_state(is_flipped)
		player.update_stats()
	
	# 更新卡牌和敌人状态
	update_cards_flipped_state(flipped)
	initialize_enemies_flipped_state(flipped)

# 添加更新卡牌翻转状态的方法
func update_cards_flipped_state(flipped: bool) -> void:
	if battle_ui and battle_ui.hand:
		for card_ui in battle_ui.hand.get_children():
			if card_ui is CardUI:
				# 设置卡牌翻转状态
				card_ui.card.set_flipped(flipped)
				# 强制重新设置卡牌，触发完整的显示更新
				card_ui._set_card(card_ui.card)


>>>>>>> Stashed changes
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
	# 战斗结束，重置灵魂能量
	_on_battle_ended()
	Events.battle_over_screen_requested.emit("Game Over!", BattleOverPanel.Type.LOSE)
	SaveGame.delete_data()


func _on_relics_activated(type: Relic.Type) -> void:
	match type:
		Relic.Type.START_OF_COMBAT:
			player_handler.start_battle(char_stats)
			battle_ui.initialize_card_pile_ui()
		Relic.Type.END_OF_COMBAT:
			# 战斗结束，重置灵魂能量
			_on_battle_ended()
			Events.battle_over_screen_requested.emit("Victorious!", BattleOverPanel.Type.WIN)


func _on_battle_ended() -> void:
	# 如果战斗发生在里世界，重置灵魂能量
	if is_flipped:
		char_stats.reset_soals()


# 战斗开始回调
func _on_battle_started() -> void:
	# 检查并显示教程
	if tutorial_system:
		tutorial_system.check_and_show_tutorial()

# 教程完成回调
func _on_tutorial_completed() -> void:
	# 恢复游戏树
	get_tree().paused = false
	

func _on_player_san_damage_taken(damage: int) -> void:
	# 处理玩家受到精神伤害的逻辑
	pass
