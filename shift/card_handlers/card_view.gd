class_name CardView
extends Control

## One card in the hand.

signal played(view: CardView)

const ART_FOLDER := "res://data/card_imgs"

@onready var visual: Control = %Visual
@onready var full_art: TextureRect = %FullArt
@onready var outline: Panel = %Outline
@onready var glow: ColorRect = %Glow

var data: CardData
var _hovered := false
var _dragging := false
var _home_tween: Tween
var _hover_tween: Tween
var hover_lift := 50.0
var hover_scale := 1.15
var _outline_style: StyleBoxFlat
var _glow_mat: ShaderMaterial

func setup(p_data: CardData) -> CardView:
	data = p_data
	if is_node_ready():
		_refresh()
	return self

func _ready():
	mouse_entered.connect(_set_hovered.bind(true))
	mouse_exited.connect(_set_hovered.bind(false))
	_outline_style = outline.get_theme_stylebox("panel").duplicate()
	outline.add_theme_stylebox_override("panel", _outline_style)
	_glow_mat = glow.material
	if data:
		_refresh()

func _refresh():
	tooltip_text = data.description
	# The PNG is the whole card: the card's `art` if set, else data/card_imgs/<id>.png
	full_art.texture = data.art if data.art else load(ART_FOLDER.path_join(String(data.id) + ".png"))
	# Special cards get a brand-new material: swapping the shader on the old one
	# keeps its uniform values (e.g. the rays' gold glow_color leaks into same-named uniforms).
	if data.glow_shader:
		_glow_mat = ShaderMaterial.new()
		_glow_mat.shader = data.glow_shader
		# A new material stores no uniform values, and the hover tween can't
		# animate from "nothing", so give intensity a starting value.
		_glow_mat.set_shader_parameter("intensity", 0.0)
		glow.material = _glow_mat

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
	_hover_tween.tween_property(visual, "position", Vector2(0, -hover_lift) if lifted else Vector2.ZERO, 0.15)
	_hover_tween.tween_property(visual, "rotation", -rotation if lifted else 0.0, 0.15)
	_hover_tween.tween_property(visual, "scale", Vector2.ONE * (hover_scale if lifted else 1.0), 0.15)
	_hover_tween.tween_property(_outline_style, "border_color", Color(1, 0.9, 0.5) if lifted else Color(0.15, 0.15, 0.15), 0.15)
	_hover_tween.tween_property(_outline_style, "shadow_size", 12 if lifted else 0, 0.15)
	_hover_tween.tween_property(_glow_mat, "shader_parameter/intensity", 1.0 if lifted else 0.0, 0.2)

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
