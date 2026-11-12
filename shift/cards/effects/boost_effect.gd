class_name BoostEffect
extends CardEffect

@export var trait_name: StringName = &""
@export_range(0.0, 1.0) var amount := 0.15

func on_played(popup: Node, _card: CardData) -> void:
    for i in FateMath.SIDES:
        if trait_name == &"" or CardData.TRAITS[i] == trait_name:
            popup.radii[i] = minf(popup.radii[i] + amount, 1.0)