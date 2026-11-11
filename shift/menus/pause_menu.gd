extends Control

const MAIN_MENU := "res://menus/main_menu.tscn"

func _ready() -> void:
	hide()
	%ResumeButton.pressed.connect(close)
	%ExitButton.pressed.connect(_exit_to_menu)

func open() -> void:
	show()
	get_tree().paused = true
	%ResumeButton.grab_focus()

func close() -> void:
	hide()
	get_tree().paused = false

# Esc opens the pause menu, and closes it again.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible:
			close()
		else:
			open()
		get_viewport().set_input_as_handled()

func _exit_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU)
