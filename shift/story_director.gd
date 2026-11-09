class_name StoryDirector
extends Node

const STORY := preload("res://data/story/the_week.tres")
const ENDLESS_SHIFT := preload("res://data/shifts/baseline.tres")
const MAIN_MENU := "res://main_menu.tscn"

@onready var shift_manager: ShiftManager = $"../ShiftManager"
@onready var ui = $"../UI"

func _ready() -> void:
    if GameState.mode == GameState.Mode.STORY:
        run_story(STORY)
    else:
        run_endless()

func run_story(story: StoryData) -> void:
    if GameState.story_index == 0:
        await play_cutscene(story.opening)

    for i in range(GameState.story_index, story.shifts.size()):
        GameState.story_index = i
        var shift: ShiftData = story.shifts[i]

        await play_cutscene(shift.cutscene_before)
        var result: Dictionary = await shift_manager.run_shift(shift)
        print("%s over: %d successes, quota met: %s" % [shift.display_name, result.successes, result.quota_met])
        await play_cutscene(shift.cutscene_after)

    await play_cutscene(story.ending)
    GameState.story_index = 0
    get_tree().change_scene_to_file(MAIN_MENU)

func run_endless() -> void:
    while true:
        await shift_manager.run_shift(ENDLESS_SHIFT)

func play_cutscene(scene: PackedScene) -> void:
    if scene == null:
        return

    var cutscene: Cutscene = scene.instantiate()
    ui.cutscene_layer.add_child(cutscene)
    await cutscene.finished
    cutscene.queue_free()