extends Control

signal rolled(success: bool)
signal closed

const SUCCESS_COLOR := Color(0.45, 0.9, 0.55)
const FAIL_COLOR := Color(0.95, 0.4, 0.4)
const AUTO_CLOSE_SECONDS := 5.0

@onready var dim: ColorRect = %Dim
@onready var panel: PanelContainer = %Panel
@onready var image: TextureRect = %Image
@onready var text: RichTextLabel = %Text
@onready var chance: Label = %Chance
@onready var played: RichTextLabel = %Played
@onready var wheel: FateWheel = %Wheel
@onready var result: Label = %Result
@onready var roll: Button = %Roll
@onready var played_pile = %PlayedPile

var data: ScenarioData
var current_chance: float = 0.0
var _has_rolled := false
var _closing := false
var _played_cards: Array[String] = []

func setup(p_data: ScenarioData) -> Control:
	data = p_data
	if is_node_ready():
		_refresh()
	return self

func _ready():
	roll.pressed.connect(_on_roll_pressed)
	# Cards can be dropped anywhere on the popup (including the dim backdrop).
	for c in find_children("*", "Control", true, false) + [self]:
		c.set_drag_forwarding(Callable(), _can_drop_card, _drop_card)
	if data:
		_refresh()
	_animate_in()

func _refresh():
	current_chance = data.base_chance
	image.texture = load(data.scenario_img) if data.scenario_img != "" else null
	image.visible = image.texture != null
	text.text = data.scenario_text.strip_edges()
	_update_chance_label()
	wheel.chance = current_chance
	wheel.spin = randf() * TAU

func _update_chance_label():
	chance.text = "Chance of success: %d%%" % roundi(current_chance * 100)

func _can_drop_card(_pos: Vector2, d: Variant) -> bool:
	return not _has_rolled and d is Dictionary and d.has("card_view")

func _drop_card(_pos: Vector2, d: Variant) -> void:
	var view: CardView = d.card_view
	apply_card(view.data)
	view.play()

## Shifts the odds by this scenario's modifier for the card.
func apply_card(card: CardData) -> void:
	var delta := data.get_delta(card)
	var view: CardView = played_pile.add_card(card)
	view.tooltip_text = "%s %+d%%" % [card.display_name, roundi(delta * 100)]
	view.set_drag_forwarding(func(_p_): return null, _can_drop_card, _drop_card)
	current_chance = clampf(current_chance + delta, 0.0, 1.0)
	var col := "#73e68c" if delta >= 0 else "#f26666"
	_played_cards.append("%s [color=%s]%+d%%[/color]" % [card.display_name, col, roundi(delta * 100)])
	played.text = ", ".join(_played_cards)
	_update_chance_label()
	create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT) \
		.tween_property(wheel, "chance", current_chance, 0.4)

func _animate_in():
	dim.modulate.a = 0.0
	panel.modulate.a = 0.0
	var t := create_tween().set_parallel()
	t.tween_property(dim, "modulate:a", 1.0, 0.25)
	t.tween_property(panel, "modulate:a", 1.0, 0.3)

func _on_roll_pressed():
	if _has_rolled:
		_close()
		return
	_has_rolled = true
	roll.disabled = true

	var success := randf() < current_chance
	await wheel.spin_to(success)

	result.text = "SUCCESS" if success else "FAILED"
	result.add_theme_color_override("font_color", SUCCESS_COLOR if success else FAIL_COLOR)

	roll.text = "Continue"
	roll.disabled = false
	roll.grab_focus()
	rolled.emit(success)

	get_tree().create_timer(AUTO_CLOSE_SECONDS).timeout.connect(_close)

func _close():
	if _closing:
		return
	_closing = true
	roll.disabled = true
	var t := create_tween().set_parallel()
	t.tween_property(dim, "modulate:a", 0.0, 0.2)
	t.tween_property(panel, "modulate:a", 0.0, 0.2)
	await t.finished
	closed.emit()
	queue_free()
