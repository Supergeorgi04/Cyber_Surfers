extends Button

func _ready():
	MenuAudioPlayer.play_music()

func _on_pressed() -> void:
	MenuAudioPlayer.stop()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
	pass # Replace with function body.
