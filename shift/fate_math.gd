class_name FateMath
extends RefCounted

const SIDES := 5
const GROWTH := 0.08

static func corner(i: int) -> Vector2:
    return Vector2.from_angle(-PI / 2.0 + TAU * i / SIDES)

static func edge_mid(i: int) -> Vector2:
    return (corner(i) + corner((i + 1) % SIDES)) / 2.0

static func base_radius(chance: float) -> float:
    return sqrt(clampf(chance, 0.0, 1.0))

static func card_growth(card: CardData, scenario: ScenarioData) -> PackedFloat32Array:
    var g := PackedFloat32Array()
    for t in CardData.TRAITS:
        g.append(card.get(t) * scenario.get_multiplier(t) * GROWTH)
    return g

static func web_points(radii: PackedFloat32Array) -> PackedVector2Array:
    var pts := PackedVector2Array()
    for i in SIDES:
        pts.append(corner(i) * radii[i])
    return pts

## Each wedge is two mirror-image triangles: centre -> corner i -> edge midpoint.
## This is the fraction of ONE such triangle covered by the web.
static func _half_fraction(ri: float, rj: float) -> float:
    if ri + rj <= 0.0:
        return 0.0
    return 2.0 * ri * ri * rj / (ri + rj)

## Fraction of wedge i covered by the web (0..1). Depends on its neighbours too.
static func wedge_fraction(radii: PackedFloat32Array, i: int) -> float:
    var prev := radii[(i + SIDES - 1) % SIDES]
    var next := radii[(i + 1) % SIDES]
    return (_half_fraction(radii[i], prev) + _half_fraction(radii[i], next)) / 2.0

static func success_chance(radii: PackedFloat32Array, weights: PackedFloat32Array) -> float:
    var total := 0.0
    var hit := 0.0
    for i in SIDES:
        total += weights[i]
        hit += weights[i] * wedge_fraction(radii, i)
    return hit / total if total > 0.0 else 0.0

static func pick_wedge(weights: PackedFloat32Array) -> int:
    var total := 0.0
    for w in weights:
        total += w

    var r := randf() * total
    for i in SIDES:
        r -= weights[i]
        if r <= 0.0:
            return i
    
    return SIDES - 1

static func random_point_in_wedge(i: int) -> Vector2:
    var c := corner(i)
    var m := edge_mid(i) if randf() < 0.5 else edge_mid((i + SIDES - 1) % SIDES)
    var a := randf()
    var b := randf()
    if a + b > 1.0:
        a = 1.0 - a
        b = 1.0 - b
    return c * a + m * b

static func roll(radii: PackedFloat32Array, weights: PackedFloat32Array) -> Dictionary:
    var wedge := pick_wedge(weights)
    var point := random_point_in_wedge(wedge)
    var success := Geometry2D.is_point_in_polygon(point, web_points(radii))
    return {"wedge": wedge, "point": point, "success": success}
