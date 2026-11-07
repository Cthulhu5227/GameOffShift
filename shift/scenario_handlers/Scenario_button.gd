extends Button

## The map marker for a scenario. ui.gd listens for `pressed` and opens the popup.

func _ready():
	var t := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	t.tween_property(self, "modulate", Color(1, 1, 1), 0.8)
	t.tween_property(self, "modulate", Color(0.7, 0.7, 0.7), 0.8)
