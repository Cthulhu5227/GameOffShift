extends AudioStreamPlayer

func _ready() -> void:
	stream = preload("res://music/placeholder.wav")
	volume_db = -10.0
	finished.connect(play)
	play()
