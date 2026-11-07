class_name CardView
extends Control

## One card in the hand. The root Control is the stable hit area that the Hand
## positions; the Visual child does the hover lift so the card doesn't flicker
## when it rises out from under the mouse.

signal played(view: CardView)

const HOVER_LIFT := 50.0
const HOVER_SCALE := 1.15
const ART_FOLDER := "res://data/card_imgs"

@onready var visual: Control = %Visual
@onready var full_art: TextureRect = %FullArt

var data: CardData
var _hovered := false
var _dragging := false
var _home_tween: Tween
var _hover_tween: Tween

func setup(p_data: CardData) -> CardView:
	data = p_data
	if is_node_ready():
		_refresh()
	return self

func _ready():
	mouse_entered.connect(_set_hovered.bind(true))
	mouse_exited.connect(_set_hovered.bind(false))
	if data:
		_refresh()

func _refresh():
	tooltip_text = data.description
	# The PNG is the whole card: the card's `art` if set, else data/card_imgs/<id>.png
	full_art.texture = data.art if data.art else load(ART_FOLDER.path_join(String(data.id) + ".png"))

## Called by the Hand to slide the card to its slot in the fan.
func move_home(pos: Vector2, rot: float) -> void:
	if _home_tween:
		_home_tween.kill()
	_home_tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_home_tween.tween_property(self, "position", pos, 0.3)
	_home_tween.tween_property(self, "rotation", rot, 0.3)

## Called by whatever the card was dropped on.
func play() -> void:
	played.emit(self)

func _set_hovered(on: bool) -> void:
	_hovered = on
	_update_hover()

func _update_hover() -> void:
	var lifted := _hovered and not _dragging
	z_index = 10 if lifted else 0
	if _hover_tween:
		_hover_tween.kill()
	_hover_tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(visual, "position", Vector2(0, -HOVER_LIFT) if lifted else Vector2.ZERO, 0.15)
	_hover_tween.tween_property(visual, "rotation", -rotation if lifted else 0.0, 0.15)
	_hover_tween.tween_property(visual, "scale", Vector2.ONE * (HOVER_SCALE if lifted else 1.0), 0.15)

func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview: CardView = load(scene_file_path).instantiate()
	preview.setup(data)
	preview.position = -size / 2.0
	preview.modulate.a = 0.9
	var holder := Control.new()
	holder.add_child(preview)
	set_drag_preview(holder)
	_dragging = true
	modulate.a = 0.3
	_update_hover()
	return {"card_view": self}

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END and _dragging:
		_dragging = false
		modulate.a = 1.0
		_update_hover()
