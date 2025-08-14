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
@export var max_mana: int
@export var starting_relic: Relic
@export var startesoals: int = 0

var mana: int : set = set_mana
var soals: int : set = set_soals
var deck: CardPile
var discard: CardPile
var draw_pile: CardPile
var ex_pile: CardPile

func init() -> void:
	draw_pile.init(1)
	discard.init(3)
	ex_pile.init(4)
	

func set_mana(value: int) -> void:
	mana = value
	stats_changed.emit()

<<<<<<< Updated upstream
=======
func set_soals(value: int) -> void:
	var old_soals = soals
	soals = clampi(value, 0, max_soals)
	stats_changed.emit()
	
	if soals == 0 and old_soals > 0:
		Events.souls_depleted.emit()

func add_soals(amount: int) -> void:
	soals = clampi(soals + amount, 0, max_soals)
	stats_changed.emit()

>>>>>>> Stashed changes

func reset_mana() -> void:
	mana = max_mana


func take_damage(damage: int) -> void:
	var initial_health := health
	super.take_damage(damage)
	if initial_health > health:
		Events.player_hit.emit()


<<<<<<< Updated upstream
=======
func set_san(value: int) -> void:
	san = clampi(value, 0, max_san)
	stats_changed.emit()

func take_san_damage(damage: int) -> void:
	set_san(san - damage)
	Events.player_san_damage_taken.emit(damage)


>>>>>>> Stashed changes
func can_play_card(card: Card) -> bool:
	return mana >= card.cost


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


# 添加重置灵魂能量的方法
func reset_soals() -> void:
	soals = 0
	stats_changed.emit()
