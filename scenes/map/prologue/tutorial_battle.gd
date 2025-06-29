extends Node
class_name TutorialBattle

# 信号
signal tutorial_completed

# 依赖项
var battle: Battle
var run_stats: RunStats

# 教程弹窗场景
var tutorial_popup_scene = preload("res://scenes/map/prologue/tutorial_popup.tscn")
var tutorial_active: bool = false

func _init(battle_ref: Battle, run_stats_ref: RunStats) -> void:
	battle = battle_ref
	run_stats = run_stats_ref

# 检查并显示教程
func check_and_show_tutorial() -> void:
	# 确保 run_stats 不为空
	if run_stats == null:
		push_warning("RunStats is null, cannot show tutorial")
		return
		
	print("Tutorial check - Chapter: %s, Room: %s" % [run_stats.chapter, run_stats.current_room_index])
	
	# 只在序章战斗中显示教程
	if run_stats.chapter != 0:
		print("Not prologue, skipping tutorial")
		return
	
	# 第一个战斗房：基础卡牌教程
	if run_stats.current_room_index == 0:
		print("Showing basic card tutorial")
		show_tutorial(get_basic_tutorial_steps())
	# 第二个战斗房：翻转世界教程
	elif run_stats.current_room_index == 1:
		print("Showing flip world tutorial")
		show_tutorial(get_flip_tutorial_steps())

# 显示教程
func show_tutorial(steps: Array[Dictionary]) -> void:
	var tutorial = tutorial_popup_scene.instantiate()
	battle.add_child(tutorial)
	tutorial.set_pages(steps)
	tutorial.tutorial_completed.connect(_on_tutorial_completed)
	battle.get_tree().paused = true
	tutorial_active = true

# 教程完成回调
func _on_tutorial_completed() -> void:
	battle.get_tree().paused = false
	tutorial_active = false
	emit_signal("tutorial_completed")

# 基础卡牌教程步骤
func get_basic_tutorial_steps() -> Array[Dictionary]:
	return [
		{
			"texture": preload("res://scenes/map/prologue/卡牌.jpg"),
			"text": "欢迎来到卡牌战斗！[b]你的卡牌位于屏幕下方。[/b]\n\n每个回合开始时，你会抽5张卡牌。"
		},
		{
			"texture": preload("res://scenes/map/prologue/卡牌.jpg"),
			"text": "[b]使用卡牌：[/b]\n点击并拖拽卡牌到敌人身上使用它。\n\n卡牌左上角显示其[b]法力消耗[/b]。"
		},
		{
			"texture": preload("res://scenes/map/prologue/卡牌.jpg"),
			"text": "[b]法力系统：[/b]\n右上角显示当前法力值。\n\n每回合开始时法力值会重置。\n\n合理规划法力使用是胜利的关键！"
		},
		{
			"texture": preload("res://scenes/map/prologue/卡牌.jpg"),
			"text": "[b]结束回合：[/b]\n用完卡牌后，点击右下角的'结束回合'按钮。\n\n之后敌人将开始行动。"
		}
	]

# 翻转世界教程步骤
func get_flip_tutorial_steps() -> Array[Dictionary]:
	return [
		{
			"texture": preload("res://scenes/map/prologue/卡牌.jpg"),
			"text": "[b]世界翻转系统：[/b]\n每个战斗有两个世界：表世界和里世界。\n\n敌人和卡牌在不同世界有不同效果。"
		},
		{
			"texture": preload("res://scenes/map/prologue/卡牌.jpg"),
			"text": "[b]翻转按钮：[/b]\n点击右下角的'进入里世界'按钮翻转世界。\n\n翻转后，敌人和卡牌效果都会变化！"
		},
		{
			"texture": preload("res://scenes/map/prologue/卡牌.jpg"),
			"text": "[b]策略性翻转：[/b]\n合理使用翻转可以：\n- 躲避敌人的强力攻击\n- 使敌人进入易伤状态\n- 增强你的卡牌效果\n\n尝试在战斗中灵活运用！"
		}
	]
