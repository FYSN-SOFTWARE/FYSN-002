class_name Player
extends Node2D

const WHITE_SPRITE_MATERIAL := preload("res://art/white_sprite_material.tres")

@export var stats: CharacterStats : set = set_character_stats

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var stats_ui: StatsUI = $StatsUI
@onready var status_handler: StatusHandler = $StatusHandler
@onready var modifier_handler: ModifierHandler = $ModifierHandler
@onready var medicine_handler: MedicineHandler = $MedicineHandler

# 添加世界翻转状态
var is_world_flipped: bool = false


func _ready() -> void:
	status_handler.status_owner = self
	medicine_handler.player = self
	# 监听世界翻转事件
	Events.world_flipped.connect(_on_world_flipped)


func _on_world_flipped(flipped: bool) -> void:
	is_world_flipped = flipped


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
	# 确保stats_ui已初始化
	if stats_ui:
		stats_ui.update_stats(stats)

# 修改为公共方法，可以被外部调用
func lose_san(amount: int) -> void:
	if stats.san <= 0:
		return
	
	stats.san -= amount
	
	# 检查san值是否清零
	if stats.san <= 0:
		Events.player_died.emit() 
		queue_free()

# 修改伤害处理方法，根据世界状态决定扣除血量还是san值
func take_damage(damage: int, which_modifier: Modifier.Type) -> void:
	if is_world_flipped:
		# 里世界：扣除san值
		lose_san(damage)
		return
		
	# 表世界：原逻辑扣除血量
	if stats.health <= 0:
		return
	
	sprite_2d.material = WHITE_SPRITE_MATERIAL
	var modified_damage := modifier_handler.get_modified_value(damage, which_modifier)
	
	var tween := create_tween()
	tween.tween_callback(Shaker.shake.bind(self, 16, 0.15))
	tween.tween_callback(stats.take_damage.bind(modified_damage))
	tween.tween_interval(0.17)
	
	tween.finished.connect(
		func():
			sprite_2d.material = null
			
			if stats.health <= 0:
				Events.player_died.emit()
				queue_free()
	)


# 添加药水
func add_medicine(medicine: Medicine) -> bool:
	return medicine_handler.add_medicine(medicine)
