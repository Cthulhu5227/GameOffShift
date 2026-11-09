extends Control

signal rolled(success: bool)
signal closed

const SUCCESS_COLOR := Color(0.45, 0.9, 0.55)
const FAIL_COLOR := Color(0.95, 0.4, 0.4)
const AUTO_CLOSE_SECONDS := 8.0

@onready var dim: ColorRect = %Dim
@onready var panel: PanelContainer = %Panel
@onready var image: TextureRect = %Image
@onready var text: RichTextLabel = %Text
@onready var chance: Label = %Chance
@onready var played: RichTextLabel = %Played
@onready var wheel: FatePentagon = %Wheel
@onready var result: Label = %Result
@onready var outcome: RichTextLabel = %Outcome
@onready var roll: Button = %Roll
@onready var played_pile = %PlayedPile

var data: ScenarioData
var current_chance: float = 0.0
var _has_rolled := false
var _closing := false
var _played_cards: Array[String] = []
var chance_bonus := 0.0
var radii := PackedFloat32Array() # web size at each pentagon corner (0..1)
var weights := PackedFloat32Array() # how often the ball lands in each wedge
var _last_card: CardData

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
	weights = data.get_weights()
	var r0 := FateMath.base_radius(data.base_chance + chance_bonus)
	radii = PackedFloat32Array()
	var labels := PackedStringArray()
	for t in CardData.TRAITS:
		radii.append(r0)
		labels.append("%s ×%s" % [String(t).capitalize(), String.num(data.get_multiplier(t))])
	current_chance = FateMath.success_chance(radii, weights)
	image.texture = load(data.scenario_img) if data.scenario_img != "" else null
	image.visible = image.texture != null
	text.text = data.scenario_text.strip_edges()
	outcome.text = ""
	wheel.labels = labels
	wheel.radii = radii.duplicate()
	_update_chance_label()

func _update_chance_label():
	chance.text = "Chance of success: %d%%" % roundi(current_chance * 100)

func _can_drop_card(_pos: Vector2, d: Variant) -> bool:
	return not _has_rolled and d is Dictionary and d.has("card_view")

func _drop_card(_pos: Vector2, d: Variant) -> void:
	var view: CardView = d.card_view
	apply_card(view.data)
	view.play()

## Grows the web's corners by the card's traits (scaled by this scenario's multipliers).
func apply_card(card: CardData) -> void:
	var before := current_chance
	var growth := FateMath.card_growth(card, data)
	for i in FateMath.SIDES:
		radii[i] = minf(radii[i] + growth[i], 1.0)
	current_chance = FateMath.success_chance(radii, weights)
	_last_card = card
	var delta := current_chance - before
	var view: CardView = played_pile.add_card(card)
	view.tooltip_text = "%s %+d%%" % [card.display_name, roundi(delta * 100)]
	view.set_drag_forwarding(func(_p_): return null, _can_drop_card, _drop_card)
	var col := "#73e68c" if delta >= 0 else "#f26666"
	_played_cards.append("%s [color=%s]%+d%%[/color]" % [card.display_name, col, roundi(delta * 100)])
	played.text = ", ".join(_played_cards)
	_update_chance_label()
	wheel.set_web(radii)

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

	# Decide the outcome first; the ball animation just shows it.
	var r := FateMath.roll(radii, weights)
	var success: bool = r.success
	await wheel.roll_to(r.point, r.wedge)

	var t: StringName = CardData.TRAITS[r.wedge]
	result.text = "%s · %s" % ["SUCCESS" if success else "FAILED", String(t).capitalize()]
	result.add_theme_color_override("font_color", SUCCESS_COLOR if success else FAIL_COLOR)
	outcome.text = data.get_outcome_text(t, _last_card, success)

	roll.text = "Continue"
	roll.disabled = false
	roll.grab_focus()
	rolled.emit(success)

	# false = this timer stops counting while the game is paused
	get_tree().create_timer(AUTO_CLOSE_SECONDS, false).timeout.connect(_close)

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
