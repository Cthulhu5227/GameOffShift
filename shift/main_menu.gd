extends Control

const GAME_SCENE := "res://world.tscn"

func _ready() -> void:
    %StoryButton.pressed.connect(_start.bind(GameState.Mode.STORY))
    %EndlessButton.pressed.connect(_start.bind(GameState.Mode.ENDLESS))
    %QuitButton.pressed.connect(get_tree().quit)

func _start(mode: int) -> void:
    GameState.mode = mode
    get_tree().change_scene_to_file(GAME_SCENE)