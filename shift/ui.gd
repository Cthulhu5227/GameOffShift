extends Control

const ScenarioButt = preload("res://scenario_handlers/scenario_button.tscn")
const ScenarioUI = preload("res://scenario_handlers/scenario.tscn")
const HAND_SIZE := 5
const HAND_HEIGHT := 200.0 #keep map buttons out from under the cards

@onready var scenario_layer: Control = $ScenarioLayer
@onready var hand = $Hand
@onready var menu_button: Button = %MenuButton
@onready var pause_menu = %PauseMenu
@onready var card_bag: CardBag = $"../CardBag"
@onready var scenario_bag: ScenarioBag = $"../ScenarioBag"

func _ready() -> void:
	menu_button.pressed.connect(pause_menu.open)
	hand.card_played.connect(_on_card_played)
	for i in HAND_SIZE:
		hand.add_card(card_bag.draw())
	makeScenario()

func randomize_position(button: Button) -> void:
	var area: Vector2 = get_viewport_rect().size
	var max_pos: Vector2 = area - button.size - Vector2(0, HAND_HEIGHT)
	button.position = Vector2(
		randf_range(0.0, max_pos.x),
		randf_range(0.0, max_pos.y)
	)

func makeScenario():
	var button = ScenarioButt.instantiate()
	randomize_position(button)
	button.pressed.connect(_open_scenario.bind(button))
	scenario_layer.add_child(button)
	return true

func _open_scenario(button: Button) -> void:
	button.queue_free()
	var popup = ScenarioUI.instantiate()
	popup.setup(scenario_bag.draw())
	popup.closed.connect(makeScenario)
	scenario_layer.add_child(popup)

func _on_card_played(card: CardData) -> void:
	card_bag.return_card(card)
	hand.add_card(card_bag.draw())
