class_name FatePentagon
extends Control

const FAIL_COLOUR := Color(0, 0, 0)
const WEB_FALLBACK_COLOUR := Color(0.067, 0.059, 0.18)
const RIM_COLOUR := Color(0.9, 0.9, 0.9)
const HIGHLIGHT_COLOUR := Color(1, 1, 1, 0.2)
const LABEL_COLOUR := Color(0.8, 0.8, 0.8)
const PENTAGRAM_COLOUR := Color(1, 1, 1, 0.35)
const MARGIN := 36.0
const BOUNCES := 4
const CIRCLE_POINTS := 96

var radii := PackedFloat32Array([0, 0, 0, 0, 0]):
	set(v):
		radii = v
		queue_redraw()

var labels := PackedStringArray()
var ball := Vector2.ZERO
var ball_visible := false
var highlight_wedge := -1

func _scale() -> float:
	return minf(size.x, size.y) / 2.0 - MARGIN

func _px(p: Vector2) -> Vector2:
	return size / 2.0 + p * _scale()

func set_web(target: PackedFloat32Array, duration := 0.4) -> void:
	var t := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_method(_lerp_web.bind(radii.duplicate(), target.duplicate()), 0.0, 1.0, duration)

func _lerp_web(k: float, from: PackedFloat32Array, to: PackedFloat32Array) -> void:
	var r := PackedFloat32Array()
	for i in FateMath.SIDES:
		r.append(lerpf(from[i], to[i], k))
	radii = r

func roll_to(target: Vector2, wedge: int, duration := 2.5) -> void:
	var path := PackedVector2Array([Vector2.ZERO])
	var angle := randf() * TAU
	for b in BOUNCES:
		# Bounce off the rim, roughly across the circle each time.
		angle += randf_range(PI * 0.6, PI * 1.4)
		path.append(Vector2.from_angle(angle) * 0.94)
	path.append(target)
	ball_visible = true
	highlight_wedge = -1
	var t := create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	t.tween_method(_move_ball.bind(path), 0.0, 1.0, duration)
	await t.finished
	highlight_wedge = wedge
	queue_redraw()

func _move_ball(k: float, path: PackedVector2Array) -> void:
	var total := 0.0
	for i in range(1, path.size()):
		total += path[i - 1].distance_to(path[i])
	var d := k * total
	for i in range(1, path.size()):
		var seg := path[i - 1].distance_to(path[i])
		if d <= seg or i == path.size() - 1:
			ball = path[i - 1].lerp(path[i], clampf(d / seg, 0.0, 1.0) if seg > 0.0 else 1.0)
			break
		d -= seg
	queue_redraw()

## Success area matches the panel behind the wheel, so it reads as a hole in the black.
func _web_colour() -> Color:
	var panel := get_theme_stylebox("panel", "PanelContainer") as StyleBoxFlat
	if panel:
		return Color(panel.bg_color, 1.0) # fully opaque
	return WEB_FALLBACK_COLOUR

func _draw() -> void:
	var centre := size / 2.0
	var r := _scale()
	var corners := PackedVector2Array()
	for i in FateMath.SIDES:
		corners.append(_px(FateMath.corner(i)))

	# 1. Fail background: a black disc
	draw_circle(centre, r, FAIL_COLOUR)
	# 2. Rolled wedge: a pie slice centred on that stat's corner
	if highlight_wedge >= 0:
		var mid_angle := FateMath.corner(highlight_wedge).angle()
		var half := PI / FateMath.SIDES
		var slice := PackedVector2Array([centre])
		for k in 25:
			slice.append(centre + Vector2.from_angle(mid_angle - half + 2.0 * half * k / 24.0) * r)
		draw_colored_polygon(slice, HIGHLIGHT_COLOUR)
	# 3. Success web (skip if it's too small to triangulate)
	if radii.size() == FateMath.SIDES and Array(radii).max() > 0.01:
		var web := PackedVector2Array()
		for p in FateMath.web_points(radii):
			web.append(_px(p))
		draw_colored_polygon(web, _web_colour())
	# 4. Pentagram (points on the circle), rim, labels
	var star := PackedVector2Array()
	for i in FateMath.SIDES + 1:
		star.append(corners[(i * 2) % FateMath.SIDES])
	draw_polyline(star, PENTAGRAM_COLOUR, 2.0, true)
	draw_arc(centre, r, 0.0, TAU, CIRCLE_POINTS, RIM_COLOUR, 3.0, true)

	var font := get_theme_default_font()
	var fs := 18
	for i in mini(labels.size(), FateMath.SIDES):
		var s := font.get_string_size(labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
		var pos := _px(FateMath.corner(i) * 1.2) + Vector2(-s.x / 2.0, s.y / 4.0)
		draw_string(font, pos, labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, fs, LABEL_COLOUR)
	# 5. Ball
	if ball_visible:
		draw_circle(_px(ball), 7.0, Color.WHITE)
		draw_arc(_px(ball), 7.0, 0, TAU, 24, Color.BLACK, 1.5, true)
