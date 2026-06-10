extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func play_music():
	if playing:
		return
	play()
