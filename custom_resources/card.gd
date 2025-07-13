class_name Card
extends EffectOwner

enum Type {ATTACK, SKILL, POWER}
enum Rarity {COMMON, UNCOMMON, RARE, LEGEND}

const RARITY_COLORS := {
	Card.Rarity.COMMON: Color.GRAY,
	Card.Rarity.UNCOMMON: Color.CORNFLOWER_BLUE,
	Card.Rarity.RARE: Color.GOLD,
	Card.Rarity.LEGEND: Color.RED
}

# 默认卡牌面配置
const DEFAULT_CARD_SIDE := {
	"id": "default_card",
	"type": Type.ATTACK,
	"rarity": Rarity.COMMON,
	"target": Effect.Target.SINGLE_ENEMY,
	"cost": 1,
	"icon": null,
	"tooltip_text": "Default Card"
}

# 导出变量组
@export_group("Card References")
@export var outcard: CardSide:
	set(value):
		outcard = value if value else _create_default_side()
@export var backcard: CardSide:
	set(value):
		backcard = value if value else _create_default_side()
		otherbackcard = backcard
@export var sound: AudioStream

@export_group("Upgrade Properties")
@export var upgrade_damage: int = 2
@export var upgrade_block: int = 2
@export var upgrade_cost: int = 0
@export_multiline var upgraded_tooltip_text: String

@export_group("Tooltips")
@export var tooltips: Array[CardTooltip]

# 运行时变量
var otherbackcard: CardSide
var isBackworld: bool = false
var cardarea: Effect.CardArea = 0
var upgraded: bool = false

func _ready():
	# 确保卡牌面初始化
	if not outcard:
		outcard = _create_default_side()
	if not backcard:
		backcard = _create_default_side()
	otherbackcard = backcard

# 创建默认卡牌面
func _create_default_side() -> CardSide:
	var side = CardSide.new()
	side.id = DEFAULT_CARD_SIDE["id"]
	side.type = DEFAULT_CARD_SIDE["type"]
	side.target = DEFAULT_CARD_SIDE["target"]
	side.cost = DEFAULT_CARD_SIDE["cost"]
	side.icon = DEFAULT_CARD_SIDE["icon"]
	return side

# 安全属性访问器
func get_current_side() -> CardSide:
	return otherbackcard if isBackworld else outcard

# 属性访问
@export var id: String:
	get: return get_current_side().id if get_current_side() else DEFAULT_CARD_SIDE["id"]

@export var type: Type:
	get: return get_current_side().type if get_current_side() else DEFAULT_CARD_SIDE["type"]

@export var rarity: Rarity:
	get: return get_current_side().rarity if get_current_side() else DEFAULT_CARD_SIDE["rarity"]

@export var target: Effect.Target:
	get: return get_current_side().target if get_current_side() else DEFAULT_CARD_SIDE["target"]

@export var cost: int:
	get: return get_current_side().cost if get_current_side() else DEFAULT_CARD_SIDE["cost"]
	set(value):
		if get_current_side():
			get_current_side().cost = value

@export var icon: Texture:
	get: return get_current_side().icon if get_current_side() else DEFAULT_CARD_SIDE["icon"]

@export var tooltip_text: String:
	get: return get_current_side().id if get_current_side() else DEFAULT_CARD_SIDE["id"]

# 战斗相关方法
func initiative() -> void:
	if outcard:
		effects = outcard.effects.duplicate()
	Events.world_flipped.connect(on_worldflip)

func on_worldflip(flipword: bool) -> void:
	isBackworld = flipword

func is_single_targeted() -> bool:
	return target == Effect.Target.SINGLE_ENEMY

func _get_targets(targets: Array[Node]) -> Array[Node]:
	if not targets:
		return []
	
	var tree := targets[0].get_tree()
	match target:
		Effect.Target.SELF:
			return tree.get_nodes_in_group("player")
		Effect.Target.ALL_ENEMIES:
			return tree.get_nodes_in_group("enemies")
		Effect.Target.EVERYONE:
			return tree.get_nodes_in_group("player") + tree.get_nodes_in_group("enemies")
		_:
			return []

func play(targets: Array[Node], char_stats: CharacterStats, modifiers: ModifierHandler) -> void:
	if not get_current_side():
		push_error("Card side is invalid!")
		return
	
	Events.card_played.emit(self)
	char_stats.mana -= cost
	
	if is_single_targeted():
		apply_effects(targets, modifiers)
	else:
		apply_effects(_get_targets(targets), modifiers)

# 升级系统
func upgrade() -> void:
	upgraded = true
	post_upgrade()
	Events.card_upgraded.emit(self)

func post_upgrade() -> void:
	pass

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	pass

# 工具提示
func get_default_tooltip() -> String:
	if upgraded && !upgraded_tooltip_text.is_empty():
		return upgraded_tooltip_text
	return tooltip_text

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return get_default_tooltip()
