class_name CardSide
extends EffectOwner

@export_group("Card Attributes")
@export var id: String
@export var type: Card.Type
@export var cost: int

@export_group("Card Visuals")
@export var icon: Texture
@export_multiline var tooltip_text: String
