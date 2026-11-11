extends AudioStreamPlayer

func _ready() -> void:
	stream = preload("res://assets/audio/placeholder.wav")
	volume_db = -10.0
	finished.connect(play)
	play()
