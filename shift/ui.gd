extends Control
const ScenarioButt = preload("res://senario_handlers/senario_button.tscn")


func _ready() -> void:
	makeSenario()
	return  

func _process(delta: float) -> void: #lol
	pass

func randomize_position(button: Button) -> void:
	var area: Vector2 = get_viewport_rect().size
	var max_pos: Vector2 = area - button.size
	button.position = Vector2(
		randf_range(0.0, max_pos.x),
		randf_range(0.0, max_pos.y)
	)

func makeSenario():
	var button = ScenarioButt.instantiate()
	randomize_position(button)
	add_child(button)
	return true
