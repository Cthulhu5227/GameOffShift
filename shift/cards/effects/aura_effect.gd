class_name AuraEffect
extends CardEffect

@export var shader: Shader

func on_played(popup: Node, _card: CardData) -> void:
    popup.wheel.add_aura(shader)