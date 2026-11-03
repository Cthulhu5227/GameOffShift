class_name CardData
extends Resource

@export var id; StringName # Card ID
@export var display_name: String
@export var number: int
@export var art: Texture2D # Texture
@export_multiline var description: String # Description of card.
@export var effects: Array[CardEffect] = [] # Possible card placement animations