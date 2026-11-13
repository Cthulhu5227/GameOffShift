class_name CardBag
extends Node

var cards: Array[CardData] = []
var _all_cards: Array[CardData] = []

func _enter_tree():
	_all_cards = load_cards("res://cards/data")
	cards = _all_cards

## Limit cards that can be pulled from per day.
func set_pool(pool: Array[CardData]) -> void:
	cards = _all_cards if pool.is_empty() else pool
	_bag.clear()

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
