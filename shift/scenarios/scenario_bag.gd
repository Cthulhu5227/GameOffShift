class_name ScenarioBag
extends Node

var scenarios: Array[ScenarioData] = []
func _ready():
	scenarios = load_scenarios("res://scenarios/data")
	
func load_scenarios(folder : String) -> Array[ScenarioData]:
	var scenarios: Array[ScenarioData] = []

	for file in ResourceLoader.list_directory(folder):
		if file.get_extension() != "tres":
			continue
		var res = load(folder.path_join(file))
		if res is ScenarioData:
			scenarios.append(res)

	return scenarios
	
var _bag: Array[ScenarioData] = [] 
func draw() -> ScenarioData:
	if _bag.is_empty():
		_bag = scenarios.duplicate()
		_bag.shuffle()
	return _bag.pop_back()
