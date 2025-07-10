class_name CharacterStats
extends Stats

@export_group("Visuals")
@export var character_name: String
@export_multiline var description: String
@export var portrait: Texture

@export_group("Gameplay Data")
@export var starting_deck: CardPile
@export var draftable_cards: CardPile
@export var cards_per_turn: int
@export var start_max_mana: int
@export var start_max_san: int
@export var start_soals: int = 0
@export var starting_relic: Relic


var deck: CardPile
var discard: CardPile
var draw_pile: CardPile
var ex_pile: CardPile

func init() -> void:
	draw_pile.init(1)
	discard.init(3)
	ex_pile.init(4)
	


func take_damage(damage: int) -> void:
	var initial_health := health
	super.take_damage(damage)
	if initial_health > health:
		Events.player_hit.emit()


func can_play_card(card: Card) -> bool:
	return true


func create_instance() -> Resource:
	var instance: CharacterStats = self.duplicate()
	instance.health = max_health
	instance.block = 0
	instance.reset_mana()
	instance.deck = instance.starting_deck.duplicate()
	instance.draw_pile = CardPile.new()
	instance.discard = CardPile.new()
	instance.ex_pile = CardPile.new()
	return instance
