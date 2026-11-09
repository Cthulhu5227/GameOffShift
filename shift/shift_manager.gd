class_name ShiftManager
extends Node

signal shift_started(shift: ShiftData)
signal fate_resolved(success: bool)
signal shift_ended(result: Dictionary)

@onready var ui = $"../UI"
@onready var card_bag: CardBag = $"../CardBag"
@onready var scenario_bag: ScenarioBag = $"../ScenarioBag"

var _shift: ShiftData
var _queue: Array[ScenarioData] = []
var _on_map := 0
var _resolved := 0
var _successes := 0

func _ready() -> void:
    ui.fate_finished.connect(_on_fate_finished)

func run_shift(shift: ShiftData) -> Dictionary:
    _shift = shift
    _on_map = 0
    _resolved = 0
    _successes = 0
    _queue = _pick_scenarios(shift)
    for i in shift.hand_size:
        ui.hand.add_card(card_bag.draw())
    shift_started.emit(shift)
    _fill_map()
    return await shift_ended

func _pick_scenarios(shift: ShiftData) -> Array[ScenarioData]:
    if not shift.scenarios.is_empty():
        return shift.scenarios.duplicate()
    
    var picked: Array[ScenarioData] = []
    for i in shift.fate_count:
        picked.append(scenario_bag.draw())
    return picked

func _fill_map() -> void:
    while _on_map < _shift.max_fates_on_map and not _queue.is_empty():
        _on_map += 1
        ui.spawn_fate(_queue.pop_front(), _shift.chance_modifier)

func _on_fate_finished(success: bool) -> void:
    _on_map -= 1
    _resolved += 1
    if success:
        _successes += 1
    
    fate_resolved.emit(success)
    for i in _shift.draw_per_fate:
        ui.hand.add_card(card_bag.draw())
    
    if _resolved >= _shift.get_fate_count():
        _end_shift()
    else:
        _fill_map()

func _end_shift() -> void:
    if not _shift.keep_leftover_cards:
        ui.discard_hand()
    shift_ended.emit({
        "shift": _shift,
        "successes": _successes,
        "failures": _resolved - _successes,
        "quota_met": _successes >= _shift.quota,
    })