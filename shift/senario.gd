extends Control

@onready var image: TextureRect = $Panel/Margin/VBox/Image
@onready var text: RichTextLabel = $Panel/Margin/VBox/Text

var data: ScenarioData

func setup(p_data: ScenarioData) -> Control:
	data = p_data
	if is_node_ready():
		_refresh()
	return self

func _ready():
	if data:
		_refresh()

func _refresh():
	image.texture = load(data.scenario_img) if data.scenario_img != "" else null
	text.text = data.scenario_text
