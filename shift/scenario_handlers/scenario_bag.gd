class_name ScenarioBag
extends Node

var scenarios: Array[ScenarioData] = []
func _ready():
	scenarios = load_scenarios("res://data/scenarios")
	
func load_scenarios(folder : String) -> Array[ScenarioData]:
	var scenarios: Array[ScenarioData] = []

	# list_directory gives the editor file names even in an exported build
	# (DirAccess would show "burnt_toast.tres.remap" there, which load() can't open).
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
