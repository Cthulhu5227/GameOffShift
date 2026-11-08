class_name Cutscene
extends Control

signal finished

@export var duration := 3.0

var_done := false

func_ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    var anim: AnimationPlayer = get_node_or_null("AnimationPlayer")
    if anim and anim.has_animation("play"):
        anim.play("play")
        await anim.animation_finished
    else:
        await get_tree().create_timer(duration, false).timeout
    finished()

func finish() -> void:
    if_done:
        return
    _done = true
    finished.emit()

func _gui_input(event: InputEvent) -> void:
    if event is InputEvenMouseButton and event.pressed:
        finished()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):
        finished()
