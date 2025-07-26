class_name Enemy
extends Area2D

const ARROW_OFFSET := 5
const WHITE_SPRITE_MATERIAL := preload("res://art/white_sprite_material.tres")

@export var stats: EnemyStats : set = set_enemy_stats

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var arrow: Sprite2D = $Arrow
@onready var stats_ui: StatsUI = $StatsUI
@onready var intent_ui: IntentUI = $IntentUI
@onready var status_handler: StatusHandler = $StatusHandler
@onready var modifier_handler: ModifierHandler = $ModifierHandler

var enemy_action_picker: EnemyActionPicker
var current_action: EnemyAction : set = set_current_action
# 添加翻转状态变量
var is_flipped: bool = false
# 添加翻转状态下的特殊属性
var flipped_damage_multiplier: float = 1.5
var flipped_health_multiplier: float = 1.5
var original_health: int = 0
var original_max_health: int  = 0
var original_damage_multiplier: float = 1.0 

func _ready() -> void:
	status_handler.status_owner = self
	# 连接世界翻转信号
	Events.world_flipped.connect(_on_world_flipped)
	# 记录原始血量
	original_max_health = stats.max_health
	original_health = stats.health

# 添加翻转事件处理
func _on_world_flipped(flipped: bool) -> void:
	is_flipped = flipped
	update_appearance()
	update_behavior()
	update_stats_display()

# 更新敌人外观
func update_appearance() -> void:
	if is_flipped:
		# 应用里世界外观
		sprite_2d.texture = preload("res://art/flipped_enemy.png")
		# 可以添加其他视觉效果，如改变颜色
		sprite_2d.modulate = Color(0.8, 0.2, 0.8) # 紫色调
	else:
		# 应用正常世界外观
		sprite_2d.texture = stats.art
		sprite_2d.modulate = Color.WHITE # 恢复原始颜色

# 更新敌人行为
func update_behavior() -> void:
	if is_flipped:
		# 在里世界中改变行为逻辑
		flipped_damage_multiplier = 1.5
		flipped_health_multiplier = 1.5
		
		# 调整血量 (保留当前血量百分比)
		var health_percentage = float(stats.health) / stats.max_health
		stats.max_health = int(original_max_health * flipped_health_multiplier)
		stats.health = int(stats.max_health * health_percentage)
	else:
		# 恢复原始行为
		flipped_damage_multiplier = 1.0
		flipped_health_multiplier = 1.0
		
		# 恢复原始血量
		stats.max_health = original_max_health
		stats.health = stats.health
	#// 重置当前行动，强制重新选择
	current_action = null
	update_action()  #// 这会触发重新选择行动
	update_intent()  #// 更新意图显示
	# 更新UI显示
	stats_ui.update_stats(stats)

# 更新血量显示
func update_stats_display() -> void:
	stats_ui.update_stats(stats)

# 在攻击计算时应用翻转倍率
func get_modified_damage(base_damage: int) -> int:
	return int(base_damage * flipped_damage_multiplier)

func set_current_action(value: EnemyAction) -> void:
	current_action = value
	update_intent()

func set_enemy_stats(value: EnemyStats) -> void:
	stats = value.create_instance()
	original_max_health = stats.max_health
	original_damage_multiplier = stats.damage_multiplier
	if not stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)
		stats.stats_changed.connect(update_action)
	
	update_enemy()


func setup_ai() -> void:
	if enemy_action_picker:
		enemy_action_picker.queue_free()
		
	var new_action_picker := stats.ai.instantiate() as EnemyActionPicker
	add_child(new_action_picker)
	enemy_action_picker = new_action_picker
	enemy_action_picker.enemy = self


func update_stats() -> void:
	stats_ui.update_stats(stats)


func update_action() -> void:
	if not enemy_action_picker:
		return
	
	if not current_action:
		current_action = enemy_action_picker.get_action()
		return
	
	var new_conditional_action := enemy_action_picker.get_first_conditional_action()
	if new_conditional_action and current_action != new_conditional_action:
		current_action = new_conditional_action


func update_enemy() -> void:
	if not stats is Stats: 
		return
	if not is_inside_tree(): 
		await ready
	
	sprite_2d.texture = stats.art
	arrow.position = Vector2.RIGHT * (sprite_2d.get_rect().size.x / 2 + ARROW_OFFSET)
	setup_ai()
	update_stats()


func update_intent() -> void:
	if current_action:
		current_action.update_intent_text()
		intent_ui.update_intent(current_action.intent)


func do_turn() -> void:
	stats.block = 0
	
	if not current_action:
		return
	
	current_action.perform_action()


func take_damage(damage: int, which_modifier: Modifier.Type) -> void:
	if stats.health <= 0:
		return
	
	sprite_2d.material = WHITE_SPRITE_MATERIAL
	var modified_damage := modifier_handler.get_modified_value(int(damage), which_modifier)
	
	var tween := create_tween()
	tween.tween_callback(Shaker.shake.bind(self, 16, 0.15))
	tween.tween_callback(stats.take_damage.bind(modified_damage))
	tween.tween_interval(0.17)

	tween.finished.connect(
		func():
			sprite_2d.material = null
			
			if stats.health <= 0:
				Events.enemy_died.emit(self)
				queue_free()
	)
	
	# 根据世界状态选择伤害类型
	var damage_type := which_modifier
	if Global.is_world_flipped && which_modifier == Modifier.Type.BIAO_DMG:
		damage_type = Modifier.Type.LI_DMG
	elif !Global.is_world_flipped && which_modifier == Modifier.Type.LI_DMG:
		damage_type = Modifier.Type.BIAO_DMG
	


func _on_area_entered(_area: Area2D) -> void:
	arrow.show()


func _on_area_exited(_area: Area2D) -> void:
	arrow.hide()
