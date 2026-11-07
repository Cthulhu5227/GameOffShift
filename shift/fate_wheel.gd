class_name FateWheel
extends Control

## A wheel split into a success slice (sized by `chance`) and a fail slice.
## The pointer sits at the top; spin_to() lands it on the requested outcome.

const SUCCESS_COLOR := Color(0.3, 0.7, 0.4)
const FAIL_COLOR := Color(0.65, 0.22, 0.22)
const RIM_COLOR := Color(0.9, 0.9, 0.9)
const POINTER_ANGLE := -PI / 2.0 # top of the wheel

var chance: float = 0.5:
	set(v):
		chance = clampf(v, 0.0, 1.0)
		queue_redraw()

var spin: float = 0.0:
	set(v):
		spin = v
		queue_redraw()

func spin_to(success: bool, duration := 2.5) -> void:
	# Pick a spot well inside the winning (or losing) slice, in wheel space.
	var success_arc := chance * TAU
	var target: float
	if success:
		target = randf_range(0.15, 0.85) * success_arc
	else:
		target = success_arc + randf_range(0.15, 0.85) * (TAU - success_arc)
	# The pointer sees wheel angle (POINTER_ANGLE - spin), so solve for spin.
	var final_spin := POINTER_ANGLE - target
	final_spin += TAU * ceil((spin - final_spin) / TAU) + TAU * 4 # a few full turns
	var t := create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "spin", final_spin, duration)
	await t.finished

func _draw() -> void:
	var c := size / 2.0
	var r := minf(size.x, size.y) / 2.0 - 14.0
	_draw_slice(c, r, spin, spin + chance * TAU, SUCCESS_COLOR)
	_draw_slice(c, r, spin + chance * TAU, spin + TAU, FAIL_COLOR)
	# Slice dividers
	if chance > 0.0 and chance < 1.0:
		for a in [spin, spin + chance * TAU]:
			draw_line(c, c + Vector2.from_angle(a) * r, RIM_COLOR, 2.0, true)
	draw_arc(c, r, 0, TAU, 96, RIM_COLOR, 3.0, true)
	draw_circle(c, 10.0, Color.BLACK)
	draw_arc(c, 10.0, 0, TAU, 32, RIM_COLOR, 2.0, true)
	# Pointer at the top, pointing down into the wheel
	var tip := c + Vector2(0, -r + 10)
	draw_colored_polygon(PackedVector2Array([
		tip, tip + Vector2(-11, -22), tip + Vector2(11, -22)]), RIM_COLOR)

func _draw_slice(c: Vector2, r: float, from: float, to: float, col: Color) -> void:
	if to - from <= 0.0001:
		return
	var pts := PackedVector2Array([c])
	var steps := maxi(2, ceili((to - from) / TAU * 96.0))
	for i in steps + 1:
		pts.append(c + Vector2.from_angle(lerpf(from, to, float(i) / steps)) * r)
	draw_colored_polygon(pts, col)
