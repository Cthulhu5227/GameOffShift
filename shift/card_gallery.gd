extends Control

const MAIN_MENU := "res://main_menu.tscn"
const CARD_FOLDER := "res://data/cards"
const ART_FOLDER := "res://data/card_imgs"
const ENTRY_WIDTH := 200.0
const ROMAN := ["0", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX", "XXI"]

@onready var grid: GridContainer = %Grid

func _ready() -> void:
    %BackButton.pressed.connect(get_tree().change_scene_to_file.bind(MAIN_MENU))
    var cards := CardBag.load_cards(CARD_FOLDER)
    cards.sort_custom(func(a, b): return a.number < b.number)
    for card in cards:
        grid.add_child(_make_entry(card))

func _make_entry(card: CardData) -> Control:
    var box := VBoxContainer.new()
    box.custom_minimum_size.x = ENTRY_WIDTH
    box.add_theme_constant_override("separation", 6)

    var art := TextureRect.new()
    art.texture = card.art if card.art else load(ART_FOLDER.path_join(String(card.id) + ".png"))
    art.custom_minimum_size = Vector2(ENTRY_WIDTH, ENTRY_WIDTH * 640.0 / 440.0)
    art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    box.add_child(art)

    var numeral: String = ROMAN[card.number] if card.number < ROMAN.size() else str(card.number)
    box.add_child(_label("%s  %s" % [numeral, card.display_name], 22, Color.WHITE))
    box.add_child(_label(_traits_text(card), 14, Color(0.6, 0.6, 0.6)))
    var desc := card.description if card.description != "" else "No description yet."
    box.add_child(_label(desc, 16, Color(0.85, 0.85, 0.85)))
    return box

## e.g. "Physical 2 · Chaos 2" (traits at 0 are left out)
func _traits_text(card: CardData) -> String:
    var parts: PackedStringArray = []
    for t in CardData.TRAITS:
        var value: int = card.get(t)
        if value > 0:
            parts.append("%s %d" % [String(t).capitalize(), value])
    return " · ".join(parts)

func _label(text: String, font_size: int, color: Color) -> Label:
    var label := Label.new()
    label.text = text
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    return label