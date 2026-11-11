extends Control

signal fate_finished(success: bool)

const ScenarioMarker = preload("res://scenario_handlers/scenario_marker.tscn")
const ScenarioUI = preload("res://scenario_handlers/scenario.tscn")

@onready var scenario_layer: Control = $ScenarioLayer
@onready var hand = $Hand
@onready var menu_button: Button = %MenuButton
@onready var pause_menu = %PauseMenu
@onready var card_bag: CardBag = $"../CardBag"
@onready var cutscene_layer: Control = $CutsceneLayer
@onready var markers: Node3D = $"../Markers"

func _ready() -> void:
	menu_button.pressed.connect(pause_menu.open)
	hand.card_played.connect(_on_card_played)

func spawn_fate(scenario: ScenarioData, chance_bonus := 0.0) -> void:
	var marker = ScenarioMarker.instantiate()
	marker.clicked.connect(_open_scenario.bind(marker, scenario, chance_bonus))
	markers.add_child(marker)
	# Random spot on the ground (X/Z; Y is up). Set after add_child so global_position works.
	marker.global_position = Vector3(randf_range(-1.5, 1.5), 0.0, randf_range(-1.5, 1.5))

func _open_scenario(marker: Area3D, scenario: ScenarioData, chance_bonus: float) -> void:
	marker.queue_free()
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
