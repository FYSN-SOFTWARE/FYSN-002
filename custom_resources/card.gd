class_name Card
extends EffectOwner

enum Type {ATTACK, SKILL, POWER}
enum Rarity {COMMON, UNCOMMON, RARE, LEGEND}
enum Target {SELF, SINGLE_ENEMY, ALL_ENEMIES, EVERYONE}

const RARITY_COLORS := {
	Card.Rarity.COMMON: Color.GRAY,
	Card.Rarity.UNCOMMON: Color.CORNFLOWER_BLUE,
	Card.Rarity.RARE: Color.GOLD,
	Card.Rarity.LEGEND: Color.RED
}

@export_group("Card Attributes")
@export var id: String
@export var type: Type
@export var rarity: Rarity
@export var target: Target
@export var cost: int
@export var exhausts: bool = false

@export_group("Card Visuals")
@export var icon: Texture
@export_multiline var tooltip_text: String
@export var outcard: CardSide
@export var backcard: CardSide
@export var sound: AudioStream

@export_group("Card Sides")
@export var front_side: CardSide
@export var back_side: CardSide

# 添加升级属性
@export var upgraded: bool = false
@export var upgrade_damage: int = 2
@export var upgrade_block: int = 2
@export var upgrade_cost: int = 0
@export_multiline var upgraded_tooltip_text: String

var cardarea: Effect.CardArea = 0
var is_flipped: bool = false

func set_flipped(flipped: bool) -> void:
	is_flipped = flipped
	# 更新当前使用的卡面
	initiative()
	# 更新卡牌属性
	if is_flipped && back_side:
		cost = back_side.cost
		icon = back_side.icon
		tooltip_text = back_side.tooltip_text
	elif front_side:
		cost = front_side.cost
		icon = front_side.icon
		tooltip_text = front_side.tooltip_text


func initiative() -> void:
	if is_flipped && back_side:
		effects = back_side.effects.duplicate()
	elif front_side:
		effects = front_side.effects.duplicate()
	else:
		push_error("Card %s has no valid side defined" % id)


func is_single_targeted() -> bool:
	return target == Target.SINGLE_ENEMY


func _get_targets(targets: Array[Node]) -> Array[Node]:
	if not targets:
		return []
		
	var tree := targets[0].get_tree()
	
	match target:
		Target.SELF:
			return tree.get_nodes_in_group("player")
		Target.ALL_ENEMIES:
			return tree.get_nodes_in_group("enemies")
		Target.EVERYONE:
			return tree.get_nodes_in_group("player") + tree.get_nodes_in_group("enemies")
		_:
			return []


func play(targets: Array[Node], char_stats: CharacterStats, modifiers: ModifierHandler) -> void:
	Events.card_played.emit(self)
	char_stats.mana -= cost
	
	if is_single_targeted():
		apply_effects(targets, modifiers)
	else:
		apply_effects(_get_targets(targets), modifiers)

# 升级卡牌
func upgrade() -> void:
	upgraded = true
	
	# 应用升级效果 - 允许同时升级多个属性
	var upgrade_log = []
	
	# 1. 处理伤害升级
	if upgrade_damage != 0:
		var damage_upgraded = false
		if outcard:
			for effect in outcard.effects:
				if effect is DamageEffect:
					effect.amount += upgrade_damage
					damage_upgraded = true
		if damage_upgraded:
			upgrade_log.append("伤害 +%d" % upgrade_damage)
	
	# 2. 处理格挡升级
	if upgrade_block != 0:
		var block_upgraded = false
		if outcard:
			for effect in outcard.effects:
				if effect is BlockEffect:
					effect.amount += upgrade_block
					block_upgraded = true
		if block_upgraded:
			upgrade_log.append("格挡 +%d" % upgrade_block)
	
	# 3. 处理消耗升级
	if upgrade_cost != 0:
		var cost_change = upgrade_cost
		cost = max(0, cost + cost_change)
		var sign = "+" if cost_change > 0 else ""
		upgrade_log.append("消耗 %s%d" % [sign, cost_change])
	
	# 更新工具提示文本
	if upgrade_log.size() > 0:
		var upgrade_text = "[升级: %s]" % ", ".join(upgrade_log)
		if upgraded_tooltip_text.is_empty():
			tooltip_text += "\n\n" + upgrade_text
		else:
			upgraded_tooltip_text += "\n\n" + upgrade_text
	else:
		# 如果没有特定效果升级，添加通用升级文本
		var upgrade_text = "[已升级]"
		if upgraded_tooltip_text.is_empty():
			tooltip_text += "\n\n" + upgrade_text
		else:
			upgraded_tooltip_text += "\n\n" + upgrade_text
	
	# 调用子类特定的升级逻辑
	post_upgrade()
	
	# 发出卡牌升级事件
	Events.card_upgraded.emit(self)

# 添加这个方法允许子类自定义升级逻辑
func post_upgrade() -> void:
	# 默认实现为空，子类可以覆盖
	pass

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	pass


# 获取当前面的工具提示
func get_current_tooltip() -> String:
	if is_flipped && back_side && !back_side.tooltip_text.is_empty():
		return back_side.tooltip_text
	return front_side.tooltip_text

# 获取对面的工具提示（用于预览）
func get_opposite_tooltip() -> String:
	if is_flipped && front_side && !front_side.tooltip_text.is_empty():
		return front_side.tooltip_text
	elif back_side:
		return back_side.tooltip_text
	return "无反面效果"


func get_default_tooltip() -> String:
	if upgraded && !upgraded_tooltip_text.is_empty():
		return upgraded_tooltip_text
	return tooltip_text


func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return get_default_tooltip()
	
