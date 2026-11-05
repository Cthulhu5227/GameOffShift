extends Control

signal rolled(success: bool)

@onready var image: TextureRect = $Panel/Margin/VBox/Image
@onready var text: RichTextLabel = $Panel/Margin/VBox/Text
@onready var chance: Label = $Panel/Margin/VBox/Chance
@onready var roll: Button = $Panel/Margin/VBox/Roll

var data: ScenarioData
var current_chance: float = 0.0

func setup(p_data: ScenarioData) -> Control:
	data = p_data
	if is_node_ready():
		_refresh()
	return self

func _ready():
	roll.pressed.connect(_on_roll_pressed)
	if data:
		_refresh()

func _refresh():
	current_chance = data.base_chance
	image.texture = load(data.scenario_img) if data.scenario_img != "" else null
	text.text = data.scenario_text
	chance.text = "Chance: %d%%" % roundi(current_chance*100)

func _on_roll_pressed():
	roll.disabled = true
	var success := randf()< current_chance
	text.text = data.scenario_text + ("\n\nSuccess!" if success else "\n\nFailed.")
	rolled.emit(success)
	await get_tree().create_timer(5.0).timeout
	get_parent().makeScenario()
	hide()
	queue_free()
