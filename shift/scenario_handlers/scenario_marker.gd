extends Area3D

## A clickable 3D marker for a scenario on the map. ui.gd listens for `clicked` and opens the popup.

signal clicked

@onready var model: Node3D = $Indicator

func _ready() -> void:
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))
	_start_bob()

func _on_input_event(_camera: Node, event: InputEvent, _pos: Vector3, _normal: Vector3, _shape: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		clicked.emit()

func _on_hover(on: bool) -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND if on else Input.CURSOR_ARROW)
	var target := Vector3.ONE * (0.3 if on else 0.25) # the model is scaled to 0.25 in the scene
	create_tween().tween_property(model, "scale", target, 0.15)

func _start_bob() -> void:
	var bob := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	bob.tween_property(model, "position:y", 0.3, 1.0)
	bob.tween_property(model, "position:y", 0.0, 1.0)
	var spin := create_tween().set_loops()
	spin.tween_property(model, "rotation:y", TAU, 4.0).as_relative()

func _exit_tree() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW) # don't leave the hand cursor stuck after a click
