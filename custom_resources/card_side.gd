class_name CardSide
extends EffectOwner

@export_group("Card Attributes")
@export var id: String
@export var type: Card.Type
@export var cost: int
@export var target: Effect.Target

@export_group("Card Visuals")
@export var icon: Texture
@export var tooltip: Array[CardTooltip] = []

# 添加升级属性
@export var upgrade_damage: int = 2
@export var upgrade_block: int = 2
@export var upgrade_cost: int = 0
@export_multiline var upgraded_tooltip_text: String
