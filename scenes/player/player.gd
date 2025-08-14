class_name Player
extends Node2D

const WHITE_SPRITE_MATERIAL := preload("res://art/white_sprite_material.tres")

@export var stats: CharacterStats : set = set_character_stats

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var stats_ui: StatsUI = $StatsUI
@onready var status_handler: StatusHandler = $StatusHandler
@onready var modifier_handler: ModifierHandler = $ModifierHandler


func _ready() -> void:
	status_handler.status_owner = self
<<<<<<< Updated upstream
=======
	# 监听世界翻转事件
	Events.world_flipped.connect(_on_world_flipped)
	Events.player_san_damage_taken.connect(_on_player_san_damage_taken)


func _on_world_flipped(flipped: bool) -> void:
	is_world_flipped = flipped
>>>>>>> Stashed changes

func _on_player_san_damage_taken(amount: int) -> void:
	print("玩家受到san伤害: ", amount)
	print("当前san值: ", stats.san)
	
	# 直接减少san值，避免循环调用
	if stats.san > 0:
		var new_san = max(0, stats.san - amount)
		stats.set_san(new_san)
		print("san值减少后: ", stats.san)
		
		# 检查san值是否清零
		if stats.san <= 0:
			Events.player_died.emit()

func set_character_stats(value: CharacterStats) -> void:
	stats = value
	
	if not stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)

	update_player()


func update_player() -> void:
	if not stats is CharacterStats: 
		return
	if not is_inside_tree(): 
		await ready

	sprite_2d.texture = stats.art
	update_stats()


func update_stats() -> void:
	stats_ui.update_stats(stats)


func take_damage(damage: int, which_modifier: Modifier.Type) -> void:
<<<<<<< Updated upstream
	if stats.health <= 0:
=======
	# 根据世界状态转换伤害类型
	var actual_modifier = which_modifier
	
	# 在里世界状态下，所有普通伤害转换为san伤害
	if is_world_flipped:
		if which_modifier == Modifier.Type.DMG_TAKEN:
			actual_modifier = Modifier.Type.SAN_DMG_TAKEN
	
	# 在表世界状态下，所有san伤害转换为普通伤害
	else:
		if which_modifier == Modifier.Type.SAN_DMG_TAKEN:
			actual_modifier = Modifier.Type.DMG_TAKEN
	
	# 然后继续原来的处理
	if stats.health <= 0 && actual_modifier != Modifier.Type.SAN_DMG_TAKEN:
>>>>>>> Stashed changes
		return
	
	sprite_2d.material = WHITE_SPRITE_MATERIAL
	
	# 根据转换后的伤害类型处理
	if actual_modifier == Modifier.Type.SAN_DMG_TAKEN:
		# SAN 伤害处理
		var modified_damage := modifier_handler.get_modified_value(
			int(damage), 
			Modifier.Type.SAN_DMG_TAKEN
		)
		
		var tween := create_tween()
		tween.tween_callback(Shaker.shake.bind(self, 16, 0.15))
		tween.tween_callback(stats.take_san_damage.bind(modified_damage))
		tween.tween_interval(0.17)

		tween.finished.connect(
			func():
				sprite_2d.material = null
				if stats.san <= 0:  # SAN 归零时的处理
					Events.player_died.emit()
		)
	else:
		# 普通伤害处理
		var modified_damage := modifier_handler.get_modified_value(
			int(damage), 
			actual_modifier
		)
		
		var tween := create_tween()
		tween.tween_callback(Shaker.shake.bind(self, 16, 0.15))
		tween.tween_callback(stats.take_damage.bind(modified_damage))
		tween.tween_interval(0.17)

		tween.finished.connect(
			func():
				sprite_2d.material = null
				
				if stats.health <= 0:
					Events.player_died.emit()
		)
