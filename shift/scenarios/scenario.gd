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
var _played_effects: Array[CardEffect] = []
var _roulette := false # set by the Wheel of Fortune: the web no longer matters
var _roulette_wheel: RouletteWheel
var _picks: HBoxContainer

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
		labels.append("%s x%s" % [String(t).capitalize(), String.num(data.get_multiplier(t))])
	current_chance = FateMath.success_chance(radii, weights)
	image.texture = load(data.scenario_img) if data.scenario_img != "" else null
	image.visible = image.texture != null
	text.text = data.scenario_text.strip_edges()
	outcome.text = ""
	wheel.labels = labels
	wheel.radii = radii.duplicate()
	_update_chance_label()

func _update_chance_label():
	if _roulette:
		chance.text = "The wheel decides now. Pick a colour."
		return
	chance.text = "Chance of success: %d%%" % roundi(current_chance * 100)

func _can_drop_card(_pos: Vector2, d: Variant) -> bool:
	return not _has_rolled and not _roulette and d is Dictionary and d.has("card_view")

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

	var effects: Array[CardEffect] = []
	effects.append_array(card.effects) # effects the card always has
	effects.append_array(data.get_card_effects(card)) # extra ones this scenario lists for the card
	for e in effects:
		e.on_played(self, card)
	_played_effects.append_array(effects)

	current_chance = FateMath.success_chance(radii, weights)
	_last_card = card
	var delta := current_chance - before
	var view: CardView = played_pile.add_card(card)
	view.tooltip_text = "%s %+d%%" % [card.display_name, roundi(delta * 100)]
	view.set_drag_forwarding(func(_p_): return null, _can_drop_card, _drop_card)
	# Cards can only grow the web, so the change is never negative.
	_played_cards.append("%s [color=#73e68c]%+d%%[/color]" % [card.display_name, roundi(delta * 100)])
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
	await wheel.roll_to(r.point, r.wedge)
	var t: StringName = CardData.TRAITS[r.wedge]
	_show_result(r.success, String(t).capitalize(), t)

## Swaps the fate pentagon for a roulette wheel and the Spin button for colour bets.
func enter_roulette() -> void:
	if _roulette:
		return
	_roulette = true

	_roulette_wheel = RouletteWheel.new()
	_roulette_wheel.custom_minimum_size = wheel.custom_minimum_size
	_roulette_wheel.modulate.a = 0.0
	_roulette_wheel.hide()
	var spinner := wheel.get_parent()
	spinner.add_child(_roulette_wheel)
	spinner.move_child(_roulette_wheel, wheel.get_index() + 1)

	_picks = _build_picks()
	var buttons_parent := roll.get_parent()
	buttons_parent.add_child(_picks)
	buttons_parent.move_child(_picks, roll.get_index())
	roll.hide()

	var t := create_tween()
	t.tween_property(wheel, "modulate:a", 0.0, 0.3)
	t.tween_callback(func():
		wheel.hide()
		_roulette_wheel.show())
	t.tween_property(_roulette_wheel, "modulate:a", 1.0, 0.3)
	_update_chance_label()

func _build_picks() -> HBoxContainer:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	for pick in [RouletteMath.Pick.RED, RouletteMath.Pick.BLACK, RouletteMath.Pick.GREEN]:
		var b := Button.new()
		b.text = "%s  (%.1f%%)" % [RouletteMath.NAMES[pick], RouletteMath.chance(pick) * 100.0]
		b.custom_minimum_size = Vector2(0, 50)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var colour: Color = RouletteMath.COLOURS[pick]
		var looks := {"normal": colour, "hover": colour.lightened(0.2),
			"pressed": colour.darkened(0.2), "disabled": colour.darkened(0.5)}
		for state in looks:
			var sb := StyleBoxFlat.new()
			sb.bg_color = looks[state]
			sb.border_color = Color(0.95, 0.85, 0.45)
			sb.set_border_width_all(2)
			sb.set_corner_radius_all(6)
			b.add_theme_stylebox_override(state, sb)
		b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			b.add_theme_color_override(c, Color.WHITE)
		b.pressed.connect(_on_pick.bind(pick))
		box.add_child(b)
	return box

func _on_pick(pick: RouletteMath.Pick) -> void:
	if _has_rolled:
		return
	_has_rolled = true
	for b: Button in _picks.get_children():
		b.disabled = true
	chance.text = "You bet on %s." % RouletteMath.NAMES[pick]

	var index := RouletteMath.spin()
	await _roulette_wheel.spin_to(index)
	var landed := RouletteMath.colour_of(index)
	_picks.hide()
	var label := "%s %d" % [RouletteMath.NAMES[landed], RouletteMath.POCKETS[index]]
	_show_result(landed == pick, label, &"chaos")

## Shows the result, swaps in the Continue button and starts the auto-close timer.
func _show_result(success: bool, label: String, t: StringName) -> void:
	result.text = "%s / %s" % ["SUCCESS" if success else "FAILED", label]
	result.add_theme_color_override("font_color", SUCCESS_COLOR if success else FAIL_COLOR)
	outcome.text = data.get_outcome_text(t, _last_card, success)

	roll.text = "Continue"
	roll.show()
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
