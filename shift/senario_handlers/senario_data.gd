class_name ScenarioData
extends Resource

@export_group("Basic Info")
@export_file("*.png", "*.jpg") var scenario_img: String
@export_multiline var scenario_text: String
@export_range(0.0, 1.0) var base_chance: float = 0.5

@export_group("Major Arcana 0-7")
@export_range(0.0, 1.0) var the_fool: float = 0.0
@export_range(0.0, 1.0) var the_magician: float = 0.0
@export_range(0.0, 1.0) var the_high_priestess: float = 0.0
@export_range(0.0, 1.0) var the_empress: float = 0.0
@export_range(0.0, 1.0) var the_emperor: float = 0.0
@export_range(0.0, 1.0) var the_hierophant: float = 0.0
@export_range(0.0, 1.0) var the_lovers: float = 0.0
@export_range(0.0, 1.0) var the_chariot: float = 0.0

@export_group("Major Arcana 8-14")
@export_range(0.0, 1.0) var strength: float = 0.0
@export_range(0.0, 1.0) var the_hermit: float = 0.0
@export_range(0.0, 1.0) var wheel_of_fortune: float = 0.0
@export_range(0.0, 1.0) var justice: float = 0.0
@export_range(0.0, 1.0) var the_hanged_man: float = 0.0
@export_range(0.0, 1.0) var death: float = 0.0
@export_range(0.0, 1.0) var temperance: float = 0.0

@export_group("Major Arcana 15-21")
@export_range(0.0, 1.0) var the_devil: float = 0.0
@export_range(0.0, 1.0) var the_tower: float = 0.0
@export_range(0.0, 1.0) var the_star: float = 0.0
@export_range(0.0, 1.0) var the_moon: float = 0.0
@export_range(0.0, 1.0) var the_sun: float = 0.0
@export_range(0.0, 1.0) var judgement: float = 0.0
@export_range(0.0, 1.0) var the_world: float = 0.0

const CARD_NAMES = [
	"the_fool", "the_magician", "the_high_priestess", "the_empress",
	"the_emperor", "the_hierophant", "the_lovers", "the_chariot",
	"strength", "the_hermit", "wheel_of_fortune", "justice",
	"the_hanged_man", "death", "temperance", "the_devil",
	"the_tower", "the_star", "the_moon", "the_sun",
	"judgement", "the_world",
]

func get_chance(card_number: int) -> float:
	return get(CARD_NAMES[card_number])
