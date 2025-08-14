# Player turn order:
# 1. START_OF_TURN Relics 
# 2. START_OF_TURN Statuses
# 3. Draw Hand
# 4. End Turn 
# 5. END_OF_TURN Relics 
# 6. END_OF_TURN Statuses
# 7. Discard Hand
class_name PlayerHandler
extends Node

const HAND_DRAW_INTERVAL := 0.25
const HAND_DISCARD_INTERVAL := 0.25

@export var relics: RelicHandler
@export var player: Player
@export var hand: Hand

var character: CharacterStats


func _ready() -> void:
	Events.card_played.connect(_on_card_played)


func start_battle(char_stats: CharacterStats) -> void:
	character = char_stats
	character.draw_pile = character.deck.custom_duplicate()
	character.draw_pile.shuffle()
	character.discard = CardPile.new()
	relics.relics_activated.connect(_on_relics_activated)
	player.status_handler.statuses_applied.connect(_on_statuses_applied)
	start_turn()


func start_turn() -> void:
	character.block = 0
	character.reset_mana()
<<<<<<< Updated upstream
=======
	# 只在表世界回复灵魂能量
	if not Global.is_world_flipped: 
		character.add_soals(2)
	
>>>>>>> Stashed changes
	relics.activate_relics_by_type(Relic.Type.START_OF_TURN)


func end_turn() -> void:
	hand.disable_hand()
	relics.activate_relics_by_type(Relic.Type.END_OF_TURN)


func draw_card() -> void:
	reshuffle_deck_from_discard()
	hand.add_card(character.draw_pile.draw_card())
	reshuffle_deck_from_discard()


func draw_cards(amount: int, is_start_of_turn_draw: bool = false) -> void:
	var tween := create_tween()
	for i in range(amount):
		tween.tween_callback(draw_card)
		tween.tween_interval(HAND_DRAW_INTERVAL)
	
	tween.finished.connect(
		func(): 
			hand.enable_hand()
			if is_start_of_turn_draw:
				Events.player_hand_drawn.emit()
	)


func discard_cards() -> void:
	if hand.get_child_count() == 0:
		Events.player_hand_discarded.emit()
		return

	var tween := create_tween()
	for card_ui: CardUI in hand.get_children():
		tween.tween_callback(character.discard.add_card.bind(card_ui.card))
		tween.tween_callback(hand.discard_card.bind(card_ui))
		tween.tween_interval(HAND_DISCARD_INTERVAL)
	
	tween.finished.connect(
		func():
			Events.player_hand_discarded.emit()
	)


func reshuffle_deck_from_discard() -> void:
	if not character.draw_pile.empty():
		return

	while not character.discard.empty():
		character.draw_pile.add_card(character.discard.draw_card())

	character.draw_pile.shuffle()


func _on_card_played(card: Card) -> void:
	if card.exhausts or card.type == Card.Type.POWER:
		return
	
	character.discard.add_card(card)


func _on_statuses_applied(type: Status.Type) -> void:
	match type:
		Status.Type.START_OF_TURN:
			draw_cards(character.cards_per_turn, true)
		Status.Type.END_OF_TURN:
			discard_cards()


func _on_relics_activated(type: Relic.Type) -> void:
	match type:
		Relic.Type.START_OF_TURN:
			player.status_handler.apply_statuses_by_type(Status.Type.START_OF_TURN)
		Relic.Type.END_OF_TURN:
			player.status_handler.apply_statuses_by_type(Status.Type.END_OF_TURN)
<<<<<<< Updated upstream
=======


# 修改伤害处理方法，根据世界状态传递正确的伤害类型
func take_damage(damage: int, which_modifier: Modifier.Type) -> void:
	# 根据世界状态选择伤害类型
	var damage_type := which_modifier
	if Global.is_world_flipped && which_modifier == Modifier.Type.DMG_DEALT:
		damage_type = Modifier.Type.SAN_DMG_DEALT
	elif !Global.is_world_flipped && which_modifier == Modifier.Type.SAN_DMG_DEALT:
		damage_type = Modifier.Type.DMG_DEALT
		
	player.take_damage(damage, damage_type)
>>>>>>> Stashed changes
