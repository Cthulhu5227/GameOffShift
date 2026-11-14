class_name RouletteEffect
extends CardEffect

## Throws away the fate web: the fate is decided by a roulette spin instead.

func on_played(popup: Node, _card: CardData) -> void:
	popup.enter_roulette()
