class_name ScenarioBag
extends Node

@export var scenarios: Array[ScenarioData] = []

var _bag: Array[ScenarioData] = [] 

func draw() -> ScenarioData:
	if _bag.is_empty():
		_bag = scenarios.duplicate()
		_bag.shuffle()
	return _bag.pop_back()
