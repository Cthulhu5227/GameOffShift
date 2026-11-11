extends Control

signal fate_finished(success: bool)

const ScenarioButton = preload("res://scenario_handlers/scenario_button.tscn")
const ScenarioUI = preload("res://scenario_handlers/scenario.tscn")
const HAND_HEIGHT := 200.0 #keep map buttons out from under the cards

@onready var scenario_layer: Control = $ScenarioLayer
@onready var hand = $Hand
@onready var menu_button: Button = %MenuButton
@onready var pause_menu = %PauseMenu
@onready var card_bag: CardBag = $"../CardBag"
@onready var cutscene_layer: Control = $CutsceneLayer

func _ready() -> void:
	menu_button.pressed.connect(pause_menu.open)
	hand.card_played.connect(_on_card_played)

func randomize_position(button: Button) -> void:
	var area: Vector2 = get_viewport_rect().size
	var max_pos: Vector2 = area - button.size - Vector2(0, HAND_HEIGHT)
	button.position = Vector2(
		randf_range(0.0, max_pos.x),
		randf_range(0.0, max_pos.y)
	)

func spawn_fate(scenario: ScenarioData, chance_bonus := 0.0) -> void:
	var button = ScenarioButton.instantiate()
	randomize_position(button)
	button.pressed.connect(_open_scenario.bind(button, scenario, chance_bonus))
	scenario_layer.add_child(button)

func _open_scenario(button: Button, scenario: ScenarioData, chance_bonus: float) -> void:
	button.queue_free()
	var popup = ScenarioUI.instantiate()
	popup.chance_bonus = chance_bonus
	popup.setup(scenario)
	var outcome := {"success": false}
	popup.rolled.connect(func(s): outcome.success = s)
	popup.closed.connect(func(): fate_finished.emit(outcome.success))
	scenario_layer.add_child(popup)

func discard_hand() -> void:
	for view in hand.get_cards():
		card_bag.return_card(view.data)
		view.queue_free()

func _on_card_played(card: CardData) -> void:
	card_bag.return_card(card)
