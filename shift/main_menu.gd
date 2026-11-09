extends Control

const GAME_SCENE := "res://world.tscn"
const CARDS_SCENE := "res://card_gallery.tscn"

func _ready() -> void:
    %StoryButton.pressed.connect(_start.bind(GameState.Mode.STORY))
    %EndlessButton.pressed.connect(_start.bind(GameState.Mode.ENDLESS))
    %CardsButton.pressed.connect(get_tree().change_scene_to_file.bind(CARDS_SCENE))
    %QuitButton.pressed.connect(get_tree().quit)

func _start(mode: int) -> void:
    GameState.mode = mode
    get_tree().change_scene_to_file(GAME_SCENE)