class_name CardData
extends Resource

const TRAITS: Array[StringName] = [&"physical", &"insight", &"charisma", &"order", &"chaos"]

@export var id: StringName # Card ID
@export var display_name: String
@export var number: int
@export var art: Texture2D # Texture
@export_multiline var description: String # Description of card.
@export var glow_shader: Shader

@export_group("Traits")
@export_range(0, 3) var physical: int = 0 # Say used for physical reqs.
@export_range(0, 3) var insight: int = 0 # 
@export_range(0, 3) var charisma: int = 0
@export_range(0, 3) var order: int = 0
@export_range(0, 3) var chaos: int = 0 

const ART_FOLDER := "res://cards/art"

## The whole-card PNG: `art` if set, else cards/art/<id>.png
func get_art() -> Texture2D:
	return art if art else load(ART_FOLDER.path_join(String(id) + ".png"))
