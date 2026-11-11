class_name CardBag
extends Node

var cards: Array[CardData] = []
func _enter_tree():
	cards = load_cards("res://data/cards")

static func load_cards(folder : String) -> Array[CardData]:
	var cards: Array[CardData] = []

	for file in ResourceLoader.list_directory(folder):
		if file.get_extension() != "tres": # the folder also has card_data.gd
			continue
		var res = load(folder.path_join(file))
		if res is CardData:
			cards.append(res)

	return cards

var _bag: Array[CardData] = []
var _held: Array[CardData] = [] 
func draw() -> CardData:
	if _bag.is_empty():
		_bag = cards.filter(func(c): return c not in _held)
		_bag.shuffle()
	var card: CardData = _bag.pop_back()
	if card:
		_held.append(card)
	return card

func return_card(card: CardData) -> void:
	_held.erase(card)
