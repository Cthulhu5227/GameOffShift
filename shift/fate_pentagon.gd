class_name FatePentagon
extends Control

const FAIL_COLOUR := Color(0.65, 0.22, 0.22)
const WEB_COLOUR := Color(0.3, 0.7, 0.4, 0.9)
const RIM_COLOUR := Color(0.9, 0.9, 0.9)
const DIVIDER_COLOUR := Color(1, 1, 1, 0.15)
const HIGHLIGHT_COLOUR := Color(1, 1, 1, 0.2)
const LABEL_COLOUR := Color(0.8, 0.8, 0.8)
const MARGIN := 36.0
const BOUNCES := 4

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
	var edge := randi() % FateMath.SIDES
	for b in BOUNCES:
		edge = (edge + 1 + randi() % (FateMath.SIDES - 1)) % FateMath.SIDES
		var a := FateMath.corner(edge)
		var c := FateMath.corner((edge + 1) % FateMath.SIDES)
		path.append(a.lerp(c, randf_range(0.2, 0.8)) * 0.94)
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

func _draw() -> void:
	var centre := size / 2.0
	var outline := PackedVector2Array()
	for i in FateMath.SIDES:
		outline.append(_px(FateMath.corner(i)))
	
	draw_colored_polygon(outline, FAIL_COLOUR)
	if highlight_wedge >= 0:
		var w := highlight_wedge
		draw_colored_polygon(PackedVector2Array([centre,
			_px(FateMath.edge_mid((w + FateMath.SIDES - 1) % FateMath.SIDES)),
			_px(FateMath.corner(w)),
			_px(FateMath.edge_mid(w))]), HIGHLIGHT_COLOUR)
	# 3. Success web (skip if it's too small to triangulate)
	if radii.size() == FateMath.SIDES and Array(radii).max() > 0.01:
		var web := PackedVector2Array()
		for p in FateMath.web_points(radii):
			web.append(_px(p))
		draw_colored_polygon(web, WEB_COLOUR)
	# 4. Wedge borders, rim, labels
	for i in FateMath.SIDES:
		draw_line(centre, _px(FateMath.edge_mid(i)), DIVIDER_COLOUR, 1.0, true)
	outline.append(outline[0])
	draw_polyline(outline, RIM_COLOUR, 3.0, true)
	var font := get_theme_default_font()
	var fs := 13
	for i in mini(labels.size(), FateMath.SIDES):
		var s := font.get_string_size(labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
		var pos := _px(FateMath.corner(i) * 1.2) + Vector2(-s.x / 2.0, s.y / 4.0)
		draw_string(font, pos, labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, fs, LABEL_COLOUR)
	# 5. Ball
	if ball_visible:
		draw_circle(_px(ball), 7.0, Color.WHITE)
		draw_arc(_px(ball), 7.0, 0, TAU, 24, Color.BLACK, 1.5, true)
