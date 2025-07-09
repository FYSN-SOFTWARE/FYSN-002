extends Node
class_name CardChooseHandler

var current_card: CardUI
var select_cards: Array
var return_butten: Button

func add_card(card_UI: CardUI) -> void:
	select_cards.append(card_UI)

func card_remove(card_UI: CardUI) -> void:
	select_cards.erase(card_UI)
	
	pass

func check_card(card_UI: CardUI) -> void:
	pass
