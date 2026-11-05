extends Button

@onready var scenario_bag: Node = $"../../ScenarioBag"
const ScenarioUIScene = preload("res://scenario.tscn")

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	print("button pressed")
	show_scenario(scenario_bag.draw())
	disabled = true
	hide()
	queue_free()
	
func show_scenario(d: ScenarioData) -> void:
	var ui = ScenarioUIScene.instantiate()
	ui.setup(d)
	get_parent().add_child(ui)
