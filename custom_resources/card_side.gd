class_name CardSide
extends Resource

@export_group("Card Attributes")
@export var id: String
@export var type: Card.Type

@export_group("Card Visuals")
@export var icon: Texture
@export_multiline var tooltip_text: String
@export var effects: Array[Effect]
