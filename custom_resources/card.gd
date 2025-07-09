class_name Card
extends EffectOwner

enum Type {ATTACK, SKILL, POWER}
enum Rarity {COMMON, UNCOMMON, RARE, LEGEND}
enum Target {SELF, SELFONE, SINGLE_ENEMY, ALL_ENEMIES, EVERYONE,SOMEONE}

const RARITY_COLORS := {
	Card.Rarity.COMMON: Color.GRAY,
	Card.Rarity.UNCOMMON: Color.CORNFLOWER_BLUE,
	Card.Rarity.RARE: Color.GOLD,
	Card.Rarity.LEGEND: Color.RED
}

@export var id: String:
	get:
		if (isBackworld):
			return otherbackcard.id
		return outcard.id
@export var type: Type:
	get:
		if (isBackworld):
			return otherbackcard.type
		return outcard.type
@export var rarity: Rarity:
	get:
		if (isBackworld):
			return otherbackcard.rarity
		return outcard.rarity
@export var target: Target:
	get:
		if (isBackworld):
			return otherbackcard.target
		return outcard.target
@export var cost: int:
	get:
		if (isBackworld):
			return otherbackcard.cost
		return outcard.cost

@export_group("Card Visuals")
@export var icon: Texture:
	get:
		if (isBackworld):
			return otherbackcard.icon
		return outcard.icon
@export var tooltip_text: String:
	get:
		if (isBackworld):
			return otherbackcard.id
		return outcard.id
#@export var tooltips: Array[CardTooltip]:
	#get:
		#if (isBackworld):
			#return otherbackcard.tooltips
		#return outcard.tooltips
		#
		
@export var outcard: CardSide
@export var backcard: CardSide
@export var sound: AudioStream

# 添加升级属性
var upgraded: bool = false
@export var upgrade_damage: int = 2
@export var upgrade_block: int = 2
@export var upgrade_cost: int = 0
@export_multiline var upgraded_tooltip_text: String

var otherbackcard: CardSide = backcard

var isBackworld :bool = false
var cardarea: Effect.CardArea = 0

#进入战斗时需要触发
func initiative() -> void:
	effects = outcard.effects.duplicate()
	Events.world_flipped.connect(on_worldflip)

#反转时触发
func on_worldflip(flipword: bool) -> void:
	isBackworld = flipword

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


func get_default_tooltip() -> String:
	if upgraded && !upgraded_tooltip_text.is_empty():
		return upgraded_tooltip_text
	return tooltip_text


func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return get_default_tooltip()
	
