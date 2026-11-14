class_name RouletteMath
extends RefCounted

## European roulette: one green 0 and 36 numbers that alternate red/black around the wheel.

enum Pick { RED, BLACK, GREEN }

## Numbers in the order they sit around a real wheel, starting at 0.
const POCKETS := [0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10,
	5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26]

const NAMES := {Pick.RED: "Red", Pick.BLACK: "Black", Pick.GREEN: "Green"}
const COLOURS := {
	Pick.RED: Color(0.72, 0.13, 0.15),
	Pick.BLACK: Color(0.08, 0.08, 0.1),
	Pick.GREEN: Color(0.1, 0.5, 0.25),
}

## Colour of the pocket at this index into POCKETS (not the printed number).
static func colour_of(index: int) -> Pick:
	if index == 0:
		return Pick.GREEN
	return Pick.RED if index % 2 == 1 else Pick.BLACK

## Picks the pocket the ball lands in. Decided before the spin animation plays.
static func spin() -> int:
	return randi() % POCKETS.size()

## Chance of winning if you bet on this colour.
static func chance(pick: Pick) -> float:
	var hits := 0
	for i in POCKETS.size():
		if colour_of(i) == pick:
			hits += 1
	return float(hits) / POCKETS.size()
