class_name ScenarioData
extends Resource

const MULTIPLIERS := {-2: 0.25, -1: 0.5, 0: 1.0, 1: 1.5, 2: 2.0}

@export_group("Basic Info")
@export_file("*.png", "*.jpg") var scenario_img: String
@export_multiline var scenario_text: String
@export_range(0.0, 1.0) var base_chance: float = 0.25

@export_group("Trait Weights")
@export_range(-2, 2) var physical: int = 0
@export_range(-2, 2) var insight: int = 0
@export_range(-2, 2) var charisma: int = 0
@export_range(-2, 2) var order: int = 0
@export_range(-2, 2) var chaos: int = 0

@export_group("Outcomes")
@export_multiline var default_success: String
@export_multiline var default_fail: String
@export var card_outcomes: Array[CardOutcome] = []

@export_group("Trait Outcomes")
@export_multiline var physical_success: String
@export_multiline var physical_fail: String
@export_multiline var insight_success: String
@export_multiline var insight_fail: String
@export_multiline var charisma_success: String
@export_multiline var charisma_fail: String
@export_multiline var order_success: String
@export_multiline var order_fail: String
@export_multiline var chaos_success: String
@export_multiline var chaos_fail: String

func get_multiplier(t: StringName) -> float:
	return MULTIPLIERS[get(t)]

func get_weights() -> PackedFloat32Array:
	var w := PackedFloat32Array()
	for t in CardData.TRAITS:
		w.append(get_multiplier(t))
	return w

func get_outcome_text(t: StringName, card: CardData, success: bool) -> String:
	var wedge_text: String = get(String(t) + ("_success" if success else "_fail"))
	if wedge_text != "":
		return wedge_text
	if card:
		for o in card_outcomes:
			if o.card and o.card.id == card.id:
				var ct := o.success_text if success else o.fail_text
				if ct != "":
					return ct
	return default_success if success else default_fail

func get_card_effects(card: CardData) -> Array[CardEffect]:
	for o in card_outcomes:
		if o.card and o.card.id == card.id:
			return o.effects
			
	return []
