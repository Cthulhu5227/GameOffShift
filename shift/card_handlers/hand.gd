extends Control

## Lays out CardViews in a fan along the bottom of the screen. It only handles display 
## ui.gd does everything else

signal card_played(data: CardData)

const CARD_SCENE = preload("res://card_handlers/card_view.tscn")

@export var card_spacing = 95.0 ##gap between card origins when there's moom
@export var max_width = 700.0## the fan never gets wider than dis
@export var fan_degrees = 4.0## tilt perard away from the middle
@export var arc_drop = 4.0##how muchuter cards sink, per step squared
@export var bottom_margin = 12.0
@export var hover_lift = 50.0
@export var hover_scale = 1.15

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE #let clicks through to the map
	resized.connect(_layout)

func add_card(data: CardData) -> CardView:
	if data==null:
		return
	var view: CardView = CARD_SCENE.instantiate()
	view.setup(data)
	view.hover_lift = hover_lift
	view.hover_scale = hover_scale
	view.played.connect(_on_card_played)
	add_child(view)
	view.position = Vector2(size.x +40, size.y -view.size.y)##from the right
	_layout()
	return view

func get_cards() -> Array[CardView]:
	var out: Array[CardView] =[]
	for c in get_children():
		if c is CardView and not c.is_queued_for_deletion():
			out.append(c)
	return out

func _on_card_played(view: CardView) -> void:
	view.queue_free()
	card_played.emit(view.data)
	_layout()

func _layout() -> void:
	var cards = get_cards()
	var n = cards.size()
	if n == 0:
		return
	var spacing = minf(card_spacing, max_width / maxf(n -1, 1))
	for i in n:
		var view = cards[i]
		var offset =i - (n -1)/ 2.0
		var pos = Vector2(
			size.x / 2.0 + offset * spacing -view.size.x / 2.0,
			size.y - view.size.y-bottom_margin + offset * offset * arc_drop)
		view.move_home(pos, deg_to_rad(offset* fan_degrees))
