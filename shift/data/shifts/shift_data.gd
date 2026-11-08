class_name ShiftData
extends Resource

## One work shift: which fates come up, what cards you get, and what
## counts as a good shift. Story mode uses a list of these (Monday..Friday);
## Endless can start from the baseline and make it harder each shift.

@export_group("Info")
@export var display_name: String = "Shift"
## Shown when the shift starts, e.g. a memo from Jeff.
@export_multiline var intro_text: String = ""

@export_group("Fates")
## How many fates happen this shift. Ignored if `scenarios` is filled in.
@export_range(1, 20) var fate_count: int = 5
## Fixed fates, in order (for Story). Leave empty to pick at random.
@export var scenarios: Array[ScenarioData] = []
## How many fate markers can be on the map at the same time.
## 1 = one at a time (like now); higher = choose which to tackle first.
@export_range(1, 10) var max_fates_on_map: int = 1
## Added to every fate's base chance this shift. Negative = harder.
@export_range(-0.5, 0.5, 0.05) var chance_modifier: float = 0.0

@export_group("Cards")
## Cards dealt at the start of the shift.
@export_range(1, 15) var hand_size: int = 6
## Extra cards drawn each time a fate is resolved (0 = no refills).
@export_range(0, 5) var draw_per_fate: int = 0
## Keep unplayed cards for the next shift, or discard them.
@export var keep_leftover_cards: bool = false

@export_group("Quota")
## Successes needed to keep Jeff happy. 0 = no quota.
@export_range(0, 20) var quota: int = 3


## The number of fates this shift will actually have.
func get_fate_count() -> int:
	return scenarios.size() if not scenarios.is_empty() else fate_count
