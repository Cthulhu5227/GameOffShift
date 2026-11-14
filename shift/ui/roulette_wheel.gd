class_name RouletteWheel
extends Control

## A spinning roulette wheel. Call spin_to() with a pocket index from RouletteMath.spin().

const RIM_COLOUR := Color(0.9, 0.9, 0.9)
const GOLD := Color(0.95, 0.85, 0.45)
const WOOD := Color(0.3, 0.17, 0.09)
const HUB_COLOUR := Color(0.12, 0.1, 0.25)
const MARGIN := 24.0
const CIRCLE_POINTS := 96

# Ring sizes, as a fraction of the wheel radius.
const POCKET_OUTER := 0.9
const POCKET_INNER := 0.64
const NUMBER_RING := 0.81
const BALL_TRACK := 0.95
const BALL_REST := 0.7

const WHEEL_TURNS := 3 # full turns the wheel makes while spinning
const BALL_LAPS := 6 # full laps the ball makes the other way

var spin_angle := 0.0 # wheel rotation; pocket 0 points this way
var ball_angle := -PI / 2.0
var ball_radius := BALL_TRACK
var ball_visible := false
var highlight := -1

func _step() -> float:
	return TAU / RouletteMath.POCKETS.size()

func _radius() -> float:
	return minf(size.x, size.y) / 2.0 - MARGIN

## Spins and lands pocket `index` under the pointer at the top. Await it.
func spin_to(index: int, duration := 4.5) -> void:
	highlight = -1
	ball_visible = true
	var top := -PI / 2.0
	# Wheel turns clockwise and must end with the pocket at the top.
	var target := top - index * _step()
	var from_wheel := spin_angle
	var to_wheel := target + TAU * ceilf((from_wheel + WHEEL_TURNS * TAU - target) / TAU)
	# Ball runs anticlockwise round the track and ends at the top too.
	var from_ball := top + randf() * TAU
	var to_ball := top - BALL_LAPS * TAU
	var t := create_tween()
	t.tween_method(_animate.bind(from_wheel, to_wheel, from_ball, to_ball), 0.0, 1.0, duration)
	await t.finished
	spin_angle = fmod(to_wheel, TAU)
	highlight = index
	queue_redraw()

func _animate(k: float, from_wheel: float, to_wheel: float, from_ball: float, to_ball: float) -> void:
	spin_angle = lerpf(from_wheel, to_wheel, 1.0 - pow(1.0 - k, 4.0))
	ball_angle = lerpf(from_ball, to_ball, 1.0 - pow(1.0 - k, 3.0))
	# Ball drops off the track into the pockets near the end.
	ball_radius = lerpf(BALL_TRACK, BALL_REST, smoothstep(0.7, 1.0, k))
	queue_redraw()

func _arc(centre: Vector2, r: float, a0: float, a1: float, steps: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for s in steps + 1:
		pts.append(centre + Vector2.from_angle(lerpf(a0, a1, float(s) / steps)) * r)
	return pts

func _draw() -> void:
	var centre := size / 2.0
	var r := _radius()
	var step := _step()
	var font := get_theme_default_font()
	var fs := 11

	# Wooden bowl and ball track
	draw_circle(centre, r, WOOD)

	# Pockets
	for i in RouletteMath.POCKETS.size():
		var a0 := spin_angle + (i - 0.5) * step
		var a1 := a0 + step
		var colour: Color = RouletteMath.COLOURS[RouletteMath.colour_of(i)]
		if i == highlight:
			colour = colour.lightened(0.45)
		var poly := _arc(centre, r * POCKET_OUTER, a0, a1, 3)
		var inner := _arc(centre, r * POCKET_INNER, a0, a1, 3)
		inner.reverse()
		poly.append_array(inner)
		draw_colored_polygon(poly, colour)
		draw_line(centre + Vector2.from_angle(a0) * r * POCKET_INNER,
			centre + Vector2.from_angle(a0) * r * POCKET_OUTER, GOLD, 1.0, true)

	# Numbers, rotated so they read outward from the centre
	for i in RouletteMath.POCKETS.size():
		var mid := spin_angle + i * step
		var s := str(RouletteMath.POCKETS[i])
		var w := font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		draw_set_transform(centre + Vector2.from_angle(mid) * r * NUMBER_RING, mid + PI / 2.0)
		draw_string(font, Vector2(-w / 2.0, fs / 3.0), s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)
	draw_set_transform_matrix(Transform2D.IDENTITY)

	# Hub with spokes that turn with the wheel
	draw_circle(centre, r * POCKET_INNER, HUB_COLOUR)
	draw_arc(centre, r * POCKET_INNER, 0.0, TAU, CIRCLE_POINTS, GOLD, 2.0, true)
	draw_arc(centre, r * POCKET_OUTER, 0.0, TAU, CIRCLE_POINTS, GOLD, 1.5, true)
	for k in 4:
		var a := spin_angle + k * PI / 2.0
		draw_line(centre, centre + Vector2.from_angle(a) * r * 0.4, GOLD, 3.0, true)
	draw_circle(centre, r * 0.1, GOLD)

	# Rim and pointer
	draw_arc(centre, r, 0.0, TAU, CIRCLE_POINTS, RIM_COLOUR, 3.0, true)
	var tip := centre + Vector2(0, -r + 6)
	draw_colored_polygon(PackedVector2Array([
		tip, centre + Vector2(-9, -r - 14), centre + Vector2(9, -r - 14)]), GOLD)

	# Ball
	if ball_visible:
		var p := centre + Vector2.from_angle(ball_angle) * r * ball_radius
		draw_circle(p, 6.0, Color.WHITE)
		draw_arc(p, 6.0, 0.0, TAU, 24, Color.BLACK, 1.5, true)
